#!/bin/bash
python3 - <<'PY'
import json, sys
try:
    rounds = json.load(open("/tmp/lfcs-drill/history.json"))
except (OSError, ValueError):
    print("No rounds recorded yet.", file=sys.stderr)
    sys.exit(1)
big = [r for r in rounds if r["asked"] >= 15]
if not big:
    print("Finish a round of at least 15 items. Try: drill -n 20", file=sys.stderr)
    sys.exit(1)
r = big[-1]
print(f"{r['cold']} cold, {r['revealed']} revealed, {r['missed']} missed "
      f"— {r['pct']}% over {r['asked']} items in {r['seconds']}s")
if r["notCold"]:
    print(f"{len(r['notCold'])} items to repair. Next step.")
PY
