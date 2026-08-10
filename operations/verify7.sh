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

# Types are checked as well as values, because valid JSON and a daemon that
# starts are two different tests. log-opts is a string map the daemon passes to
# the driver untouched, so a bare 3 there fails to unmarshal; live-restore is a
# real boolean, so a quoted "true" fails the same way. Both parse cleanly under
# python3 -m json.tool, which is exactly why the learner needs telling.
val() { python3 -c "
import json,sys
d=json.load(open('$conf'))
cur=d
for k in sys.argv[1].split('.'):
    cur=cur.get(k) if isinstance(cur,dict) else None
    if cur is None: break
print('' if cur is None else type(cur).__name__ + ':' + str(cur))
" "$1" 2>/dev/null; }

driver="$(val 'log-driver')"
case "$driver" in
  str:json-file) ;;
  "") note "no log-driver set, so the daemon keeps whatever its default is" ;;
  *) note "log-driver is '${driver#*:}', not json-file" ;;
esac

maxsize="$(val 'log-opts.max-size')"
case "$maxsize" in
  str:?*) ;;
  "") note "no log-opts.max-size, so container logs grow until the disk is full" ;;
  *) note "log-opts.max-size is a JSON ${maxsize%%:*}, not a string; log-opts is a string map, so it has to be quoted (\"10m\")" ;;
esac

maxfile="$(val 'log-opts.max-file')"
case "$maxfile" in
  str:?*) ;;
  "") note "no log-opts.max-file, so rotated logs are never discarded" ;;
  *) note "log-opts.max-file is a JSON ${maxfile%%:*}, not a string; log-opts is a string map, so it has to be quoted (\"3\")" ;;
esac

live="$(val 'live-restore')"
case "$live" in
  bool:True) ;;
  "") note "live-restore is unset; without it, restarting the daemon stops every container" ;;
  str:*) note "live-restore is the string \"${live#*:}\", not a boolean; that is valid JSON and the daemon still refuses to start on it" ;;
  bool:False) note "live-restore is false; without it, restarting the daemon stops every container" ;;
  *) note "live-restore is a JSON ${live%%:*}, not true" ;;
esac
exit "$bad"
