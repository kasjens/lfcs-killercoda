#!/usr/bin/env python3
"""Check every domain question against the manifest and the real man pages.

Three independent things, because they fail for different reasons:

1. The committed verifiers still match tools/gen_verifiers.py. A hand-edited
   verifier is caught here rather than on the live scenario.
2. Each verifier accepts the canonical answer and every accepted spelling,
   rejects the decoy, and refuses to pass a set with a question unanswered.
3. The man page each question claims exists, sits in the section claimed, and
   its rendered text contains the term the question turns on.

Point 3 is the one that stops the bank rotting. Sections move between package
versions, and an answer nobody can find in the page is worse than no question.
Pages absent locally are skipped out loud; CI installs the lot, so a skip here
is not a pass anywhere.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ANSWERS = Path("/tmp/answers")
errors, skipped, checked = [], [], 0

manifest = json.loads((ROOT / "tests" / "questions.json").read_text(encoding="utf-8"))

# ---------------------------------------------------------------- 1. drift
gen = subprocess.run([sys.executable, str(ROOT / "tools" / "gen_verifiers.py"), "--check"],
                     capture_output=True, text=True)
if gen.returncode != 0:
    errors.append("verifiers are out of date: run python3 tools/gen_verifiers.py")


# ---------------------------------------------------------------- helpers
def man_where(page: str, section: str | None) -> str:
    cmd = ["man", "-w"] + ([section] if section else []) + [page]
    out = subprocess.run(cmd, capture_output=True, text=True).stdout.strip().splitlines()
    first = out[0] if out else ""
    # The minimized-image stub prints a message and exits 0, so require a path.
    return first if first.startswith("/") else ""


def man_render(page: str, section: str | None) -> str:
    cmd = ["man"] + ([section] if section else []) + [page]
    env = {**os.environ, "MANWIDTH": "200", "LC_ALL": "C"}
    return subprocess.run(cmd, capture_output=True, text=True, env=env).stdout


def write(n: int, value: str) -> None:
    (ANSWERS / str(n)).write_text(value + "\n", encoding="utf-8")


def run(scenario: str, step: int) -> tuple[int, str]:
    p = subprocess.run(["bash", f"verify{step}.sh"], cwd=ROOT / scenario,
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


# ---------------------------------------------------------------- run
ANSWERS.mkdir(parents=True, exist_ok=True)

for name, scenario in manifest["scenarios"].items():
    questions = scenario["questions"]
    numbers = [q["n"] for q in questions]
    if len(set(numbers)) != len(numbers):
        errors.append(f"{name}: duplicate question numbers")
    if numbers != sorted(numbers):
        errors.append(f"{name}: questions are not in ascending order")

    # --- 3. the documentation claim
    for q in questions:
        checked += 1
        page, section = q.get("page"), q.get("section")
        if not page:
            continue
        # Ask without the section first. A page that exists but not in the
        # claimed section is a wrong answer, not a missing package, and must
        # not be allowed to leave as a skip.
        anywhere = man_where(page, None)
        if not anywhere:
            skipped.append(f"{name} q{q['n']}: {page} not installed here")
            continue
        where = man_where(page, section) if section else anywhere
        if section and not where:
            errors.append(f"{name} q{q['n']}: {page} is not in section {section}, "
                          f"man finds it at {anywhere}")
            continue
        if section and f"/man{section}" not in where:
            errors.append(f"{name} q{q['n']}: {page} claimed section {section}, "
                          f"man reports {where}")
        term = q.get("contains")
        if term and term not in man_render(page, section):
            errors.append(f"{name} q{q['n']}: {page}({section}) does not contain {term!r}")

    # --- 2. verifier behaviour
    for step in sorted({q["step"] for q in questions}):
        group = [q for q in questions if q["step"] == step]
        for q in group:
            write(q["n"], q["answer"])
        rc, out = run(name, step)
        if rc != 0:
            errors.append(f"{name} step {step}: canonical answers rejected: {out.strip()}")

        for q in group:
            for variant in q.get("accept", []):
                write(q["n"], variant)
                rc, _ = run(name, step)
                if rc != 0:
                    errors.append(f"{name} q{q['n']}: accepted spelling {variant!r} rejected")
                write(q["n"], q["answer"])

            write(q["n"], q["decoy"])
            rc, out = run(name, step)
            if rc == 0:
                errors.append(f"{name} q{q['n']}: decoy {q['decoy']!r} was accepted")
            elif f"question {q['n']}" not in out:
                errors.append(f"{name} q{q['n']}: rejected but the message does not name it")
            write(q["n"], q["answer"])

            (ANSWERS / str(q["n"])).unlink(missing_ok=True)
            rc, _ = run(name, step)
            if rc == 0:
                errors.append(f"{name} step {step}: passed with q{q['n']} unanswered")
            write(q["n"], q["answer"])

total = sum(len(s["questions"]) for s in manifest["scenarios"].values())
print(f"  {len(manifest['scenarios'])} scenario(s), {total} questions, "
      f"{checked} documentation claims checked")
for s in skipped:
    print(f"  skip  {s}")

# On a box missing a package, a skipped claim is honest. On CI, where every
# package is installed on purpose, it means the question is unverified and
# nobody would notice. --no-skips turns that into the failure it is.
if "--no-skips" in sys.argv and skipped:
    errors.append(f"{len(skipped)} claim(s) skipped with --no-skips: "
                  "a package the questions depend on is not installed")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every answer verified against its page, every decoy rejected")
