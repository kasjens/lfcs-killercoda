#!/bin/bash
# Step 2: time synchronisation. chronyd is not running here, so this reads the
# configuration. The step says so.
bad=0
note() { echo "$1" >&2; bad=1; }

conf=""
for f in /etc/chrony/chrony.conf /etc/chrony.conf; do
  [ -f "$f" ] && conf="$f"
done
[ -n "$conf" ] || { echo "no chrony.conf found in /etc/chrony/ or /etc" >&2; exit 1; }

# server or pool, either is a correct answer to "use this time source".
src="$(grep -hE '^[[:space:]]*(server|pool)[[:space:]]+time\.example\.com' "$conf" 2>/dev/null | tail -n1)"
if [ -z "$src" ]; then
  note "no server or pool line for time.example.com in $conf"
else
  # iburst shortens the initial sync from minutes to seconds.
  printf '%s' "$src" | grep -q 'iburst' \
    || note "the time.example.com line has no iburst option"
fi

# makestep lets chronyd jump a large offset instead of slewing it slowly,
# which matters on a box whose clock is badly wrong at boot.
grep -qE '^[[:space:]]*makestep[[:space:]]+' "$conf" 2>/dev/null \
  || note "no makestep directive in $conf"

# No daemon validation here on purpose. `chronyd -Q` looks like a dry run but
# still performs a real time query, so against an unreachable server it blocks
# until it times out. A verifier must not do network I/O.

exit "$bad"
