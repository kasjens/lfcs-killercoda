#!/bin/bash
python3 - <<'PY'
import json, os, sys

# drill.py honours LFCS_DRILL_STATE, so the verifier has to look where the
# drill was actually told to write rather than assume the default.
state = os.environ.get("LFCS_DRILL_STATE", "/tmp/lfcs-drill")
try:
    rounds = json.load(open(os.path.join(state, "history.json")))
except (OSError, ValueError):
    print("No rounds recorded yet.", file=sys.stderr)
    sys.exit(1)

# The full round from step 2 is the most recent scored round that was not
# itself a repair pass. Size alone cannot tell the two apart: a learner who
# revealed sixteen items gets a sixteen-item review round, which used to be
# mistaken for the full round and reported back as "clean".
full = None
for i, r in enumerate(rounds):
    if r.get("asked", 0) >= 15 and not r.get("review"):
        full = i

if full is None:
    print("Finish the full round in the previous step first.", file=sys.stderr)
    sys.exit(1)

if not rounds[full].get("notCold"):
    print("Full round was clean, nothing needed repairing.")
    sys.exit(0)

# Any later round used to count, so `drill -t sections -n 3` passed this step.
if not any(r.get("review") for r in rounds[full + 1:]):
    print("Run: drill --review", file=sys.stderr)
    sys.exit(1)

print("Repair round done.")
PY
