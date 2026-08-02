#!/bin/bash
python3 - <<'PY'
import json, sys
try:
    rounds = json.load(open("/tmp/lfcs-drill/history.json"))
except (OSError, ValueError):
    print("No finished round yet. Run: drill -t sections -n 8", file=sys.stderr)
    sys.exit(1)
if not any(r["asked"] >= 5 for r in rounds):
    print("Finish a round of at least 5 items first.", file=sys.stderr)
    sys.exit(1)
last = rounds[-1]
print(f"Last round: {last['cold']}/{last['asked']} produced cold ({last['pct']}%)")
PY
