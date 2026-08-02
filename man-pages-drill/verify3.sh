#!/bin/bash
python3 - <<'PY'
import json, sys
try:
    rounds = json.load(open("/tmp/lfcs-drill/history.json"))
except (OSError, ValueError):
    print("No rounds recorded yet.", file=sys.stderr)
    sys.exit(1)
scored = [r for r in rounds if r["asked"] >= 15]
if not scored:
    print("Finish the full round in the previous step first.", file=sys.stderr)
    sys.exit(1)
if not scored[-1]["notCold"]:
    print("Full round was clean — nothing needed repairing.")
    sys.exit(0)
if len(rounds) <= rounds.index(scored[-1]) + 1:
    print("Run: drill --review", file=sys.stderr)
    sys.exit(1)
print("Repair round done.")
PY
