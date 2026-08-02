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
big = [r for r in rounds if r.get("asked", 0) >= 15]
if not big:
    print("Finish a round of at least 15 items. Try: drill -n 20", file=sys.stderr)
    sys.exit(1)
r = big[-1]
print(f"{r['cold']} cold, {r['revealed']} revealed, {r['missed']} missed "
      f"— {r['pct']}% over {r['asked']} items in {r['seconds']}s")
if r["notCold"]:
    print(f"{len(r['notCold'])} items to repair. Next step.")
PY
