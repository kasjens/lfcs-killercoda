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

# If the binary is here, let it judge its own config.
if command -v chronyd >/dev/null 2>&1; then
  chronyd -Q -f "$conf" >/dev/null 2>&1 || note "chronyd rejects $conf"
fi

exit "$bad"
