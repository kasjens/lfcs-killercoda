#!/bin/bash
# Step 7: container engine configuration. Reads the daemon configuration and
# insists it is valid JSON, because a malformed file stops the engine starting.
bad=0
note() { echo "$1" >&2; bad=1; }
conf=/etc/docker/daemon.json

[ -f "$conf" ] || { echo "$conf does not exist" >&2; exit 1; }

if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$conf" 2>/dev/null; then
  echo "$conf is not valid JSON, so the engine would refuse to start" >&2
  exit 1
fi

val() { python3 -c "
import json,sys
d=json.load(open('$conf'))
cur=d
for k in sys.argv[1].split('.'):
    cur=cur.get(k) if isinstance(cur,dict) else None
    if cur is None: break
print('' if cur is None else cur)
" "$1" 2>/dev/null; }

driver="$(val 'log-driver')"
[ "$driver" = "json-file" ] || note "log-driver is '${driver:-unset}', not json-file"

maxsize="$(val 'log-opts.max-size')"
[ -n "$maxsize" ] || note "no log-opts.max-size, so container logs grow until the disk is full"

maxfile="$(val 'log-opts.max-file')"
[ -n "$maxfile" ] || note "no log-opts.max-file, so rotated logs are never discarded"

live="$(val 'live-restore')"
case "$live" in
  True|true) ;;
  *) note "live-restore is '${live:-unset}'; without it, restarting the daemon stops every container" ;;
esac
exit "$bad"
