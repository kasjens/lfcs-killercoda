#!/bin/bash
python3 - <<'PY'
import json, os, sys

# drill.py honours LFCS_DRILL_STATE, so the verifier has to look where the
# drill was actually told to write rather than assume the default.
state = os.environ.get("LFCS_DRILL_STATE", "/tmp/lfcs-drill")
try:
    rounds = json.load(open(os.path.join(state, "history.json")))
except (OSError, ValueError):
    print("No finished round yet. Run: drill -t sections -n 8", file=sys.stderr)
    sys.exit(1)
if not any(r.get("asked", 0) >= 5 for r in rounds):
    print("Finish a round of at least 5 items first.", file=sys.stderr)
    sys.exit(1)
last = rounds[-1]
print(f"Last round: {last.get('cold', 0)}/{last.get('asked', 0)} "
      f"produced cold ({last.get('pct', 0)}%)")
PY
