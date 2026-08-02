#!/usr/bin/env python3
"""A full round, answered correctly throughout, must score 100% cold.

test_bank.py checks the matcher against the bank in isolation. This plays a
whole round through the real program instead: every blank of every item, fed
the canonical answer, driven over a pipe. A matcher or prompt regression shows
up here as a correct answer being marked wrong, which is the one failure a
learner cannot argue with.

The item order is reproduced in this process using the same seed and the same
call drill.main() makes, rather than assuming random.sample stays stable
across CPython releases. Same interpreter, same order, so the answers line up.
"""
import json
import os
import random
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "man-pages-drill" / "assets"
DRILL = ASSETS / "drill.py"
SEED = 1

errors = []

bank = json.loads((ASSETS / "bank.json").read_text(encoding="utf-8"))
questions = bank["questions"]
count = len(questions)

# Mirrors drill.main(): rng.sample(pool, min(args.count, len(pool))).
chosen = random.Random(SEED).sample(questions, min(count, len(questions)))
answers = [blank["answer"] for q in chosen for blank in q["blanks"]]

with tempfile.TemporaryDirectory() as state:
    env = {**os.environ, "LFCS_DRILL_STATE": state, "NO_COLOR": "1"}
    proc = subprocess.run(
        [sys.executable, str(DRILL), "-n", str(count), "--seed", str(SEED)],
        input="".join(a + "\n" for a in answers),
        capture_output=True, text=True, env=env, timeout=120)

    if proc.returncode != 0:
        errors.append(f"drill exited {proc.returncode}: "
                      f"{proc.stderr.strip().splitlines()[-1:] or ['no stderr']}")

    history_file = Path(state) / "history.json"
    if not history_file.is_file():
        errors.append("no history.json written, so the round never finished")
        round_ = {}
    else:
        round_ = json.loads(history_file.read_text(encoding="utf-8"))[-1]

    # The three buckets are kept apart on purpose, so check them apart. A round
    # that quit early reports a clean pct over the handful of items it managed.
    if round_:
        if round_.get("asked") != count:
            errors.append(f"asked {round_.get('asked')} of {count} items, "
                          "so the round ended early")
        if round_.get("cold") != count:
            errors.append(f"{round_.get('cold')} of {count} produced cold, "
                          f"{round_.get('missed')} missed, "
                          f"{round_.get('revealed')} revealed")
        if round_.get("pct") != 100:
            errors.append(f"scored {round_.get('pct')}%, expected 100%")
        if round_.get("notCold"):
            ids = round_["notCold"]
            for qid in ids:
                q = next((x for x in questions if x["id"] == qid), None)
                shown = [b["answer"] for b in q["blanks"]] if q else ["?"]
                errors.append(f"item {qid} rejected its own answer: {shown}")

    # Every history key the drill scenario's verifiers read must be present.
    for key in ("finished", "topic", "asked", "planned", "cold", "revealed",
                "missed", "pct", "xp", "seconds", "notCold"):
        if round_ and key not in round_:
            errors.append(f"history entry has no {key!r}, "
                          "which the drill verifiers read")

print(f"  {count} items, {len(answers)} blanks fed the canonical answer, "
      f"{round_.get('pct', 0)}% cold")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  full round clean, history shape intact")
