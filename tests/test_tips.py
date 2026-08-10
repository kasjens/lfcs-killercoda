#!/usr/bin/env python3
"""Every tip has to name a source that contains the answer.

test_questions.py checks the lookup questions against their pages. Nothing
checked the *tips*, and three of them named a page the answer is provably not
in:

  - operations step 7 said `man docker`. That is the client; the daemon is
    dockerd(8), and neither page has max-size in it at all.
  - networking step 8 said the nginx directive reference is in
    /usr/share/doc/nginx. That directory is a changelog and a copyright file.
  - operations step 3 sent you to systemd.timer(5) for a solution that writes
    a service unit, and ExecStart= is in systemd.service(5).

All three were found by a learner running the scenario, not here. A tip that
names a source the answer is not in is worse than no tip, because it converts
a search problem into a trust problem: the learner assumes they searched
badly.

So, for every step with a Tip and a Solution:

1. Every `man [SECTION] PAGE` in the tip must resolve, and where a section is
   given the page must really live in it.
2. The settings the solution depends on -- directives, long options, JSON keys
   -- must appear in something the tip points at. That is the rendered man
   pages plus any file the tip tells the learner to read, because "the man
   page defers, here is what does have it" is a correct tip and has to pass.

Where a tip legitimately does not cover a needle, questions.json carries an
entry under `tip_exemptions` naming the needle and why. An exemption is a
claim about a page's contents, so it says what it is relying on.

  python3 tests/test_tips.py             skip what is not installed here
  python3 tests/test_tips.py --no-skips  a skip is a failure (CI)
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

# A fixed environment so a stray MANPAGER or MANSECT cannot change what a page
# renders as. MANPATH is passed through, because that is the only way to check
# this against pages unpacked from a .deb rather than installed.
MAN_ENV = {"PATH": "/usr/bin:/bin:/usr/sbin:/sbin", "MANWIDTH": "200"}
if os.environ.get("MANPATH"):
    MAN_ENV["MANPATH"] = os.environ["MANPATH"]

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = json.loads((ROOT / "tests" / "questions.json").read_text(encoding="utf-8"))
EXEMPT = MANIFEST.get("tip_exemptions", {})

TIP = re.compile(r"<summary>Tip.*?</details>", re.S)
SOLUTION = re.compile(r"<summary>Solution</summary>.*?</details>", re.S)
FENCED = re.compile(r"```\n(.*?)```", re.S)
MANCALL = re.compile(r"^\s*man\s+(?:-\S+\s+)*(?:([1-9])\s+)?([A-Za-z0-9._+-]+)\s*$", re.M)
# A file the tip tells the learner to *open*, which is a claim that the answer
# is in it. Only the reading commands count: `du -ah /srv/data` names a path
# the task operates on, not a source, and treating it as one turns every step
# that touches a file into an unchecked skip.
READERS = ("cat", "grep", "less", "head", "tail", "view", "zgrep", "awk")
READS = re.compile(r"(?<![\w.-])(/[A-Za-z0-9._+-]+(?:/[A-Za-z0-9._+-]+)+)")

# What a solution depends on. Each pattern is narrow on purpose: a needle that
# is really a hostname or a username produces an exemption that teaches
# nothing, and a test nobody trusts gets switched off.
NEEDLES = (
    re.compile(r"(?<![\w-])(--[a-z][a-z0-9-]{2,})"),        # --timeout
    re.compile(r"(?<![\w-])(-[a-z]{3,})="),                 # -fstype=
    re.compile(r"^([A-Z][A-Za-z]+)=", re.M),                # ExecStart=
    re.compile(r'"([a-z][a-z0-9_.-]*)"\s*:'),               # "max-size":
    re.compile(r"^([A-Z][A-Za-z-]+):\s", re.M),             # Pin-Priority:
)
# Directives inside a braced block: nginx, and anything else that looks like
# it. Restricted to braces because a bare `key value` line is as often a
# username and a limit as it is a directive.
BLOCK = re.compile(r"\{(.*?)\}", re.S)
BLOCK_DIRECTIVE = re.compile(r"^\s*([a-z][a-z0-9_]{2,})\s+\S", re.M)


def render(section, page):
    """The page as text, or None where it is not installed here."""
    cmd = ["man", "-P", "cat"] + ([section] if section else []) + [page]
    p = subprocess.run(cmd, capture_output=True, text=True, env=MAN_ENV)
    return p.stdout if p.returncode == 0 and p.stdout.strip() else None


def located(section, page):
    """Where man says the page is, so the claimed section can be checked."""
    cmd = ["man", "-w"] + ([section] if section else []) + [page]
    p = subprocess.run(cmd, capture_output=True, text=True, env=MAN_ENV)
    out = p.stdout.strip().splitlines()
    return out[0] if p.returncode == 0 and out else ""


def needles(solution):
    """The settings a solution stands on, from its fenced block."""
    block = FENCED.search(solution)
    if not block:
        return set()
    # printf-built config arrives as one line with literal \n in it. Without
    # this every directive reads as nDescription and matches nothing.
    text = block.group(1).replace("\\n", "\n").replace("\\t", "\t")
    found = set()
    for pattern in NEEDLES:
        found |= set(pattern.findall(text))
    for inner in BLOCK.findall(text):
        found |= set(BLOCK_DIRECTIVE.findall(inner))
    return found


errors, skipped, checked = [], [], 0

for md in sorted(ROOT.glob("*/step*.md")):
    where = str(md.relative_to(ROOT))
    text = md.read_text(encoding="utf-8")
    tip, solution = TIP.search(text), SOLUTION.search(text)
    if not tip or not solution:
        continue
    # A lookup step's solution is its recorded answers, which test_questions.py
    # already checks against the pages they name.
    if re.search(r"^\s*answer\s+\d+\s", solution.group(0), re.M):
        continue

    sources, missing_pages = [], False
    for section, page in MANCALL.findall(tip.group(0)):
        checked += 1
        path = located(section, page)
        if not path.startswith("/"):
            skipped.append(f"{where}: {page}({section or '?'}) is not installed here")
            missing_pages = True
            continue
        real = re.search(r"/man([^/]+)/", path)
        if section and real and not real.group(1).startswith(section):
            errors.append(f"{where}: the tip says `man {section} {page}` but the "
                          f"page is {path}")
            continue
        body = render(section, page)
        if body:
            sources.append(body)

    # Whatever else the tip tells the learner to read. This is what lets a tip
    # say "the man page defers, the answer is in this file" and still pass.
    for block in FENCED.findall(tip.group(0)):
        for line in block.splitlines():
            if line.strip().split(" ")[0] not in READERS:
                continue
            for path in READS.findall(line):
                f = Path(path)
                if f.is_file():
                    sources.append(f.read_text(encoding="utf-8", errors="replace"))
                elif not f.exists():
                    skipped.append(f"{where}: the tip reads {path}, which is not here")
                    missing_pages = True

    if not sources:
        continue
    corpus = "\n".join(sources).lower()
    exempt = EXEMPT.get(where, {})
    for needle in sorted(needles(solution.group(0))):
        checked += 1
        if needle.lower() in corpus:
            continue
        if needle in exempt:
            continue
        if missing_pages:
            skipped.append(f"{where}: cannot look for '{needle}', a source is missing")
            continue
        errors.append(f"{where}: the solution needs '{needle}' and nothing the "
                      f"tip names contains it")

print(f"  {checked} tip claim(s) checked across "
      f"{len(list(ROOT.glob('*/step*.md')))} step(s)")
for s in skipped:
    print(f"  skip  {s}")

if "--no-skips" in sys.argv and skipped:
    errors.append(f"{len(skipped)} claim(s) skipped with --no-skips: a tip names "
                  "something this box does not have, so it went unchecked")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every tip names a source that has the answer in it")
