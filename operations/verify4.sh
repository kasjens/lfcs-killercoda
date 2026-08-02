#!/bin/bash
# Step 4: repositories and pinning.
bad=0
note() { echo "$1" >&2; bad=1; }

src=""
for f in /etc/apt/sources.list.d/lfcs.list /etc/apt/sources.list.d/lfcs.sources; do
  [ -f "$f" ] && src="$f"
done
[ -n "$src" ] || { echo "no lfcs source under /etc/apt/sources.list.d" >&2; exit 1; }

body="$(grep -vE '^[[:space:]]*(#|$)' "$src")"
printf '%s' "$body" | grep -q 'https://repo.example.com' \
  || note "the source does not point at https://repo.example.com"
printf '%s' "$body" | grep -qE 'stable' \
  || note "the source does not name the stable suite"

# An unsigned repository is the thing apt refuses by default, and telling it
# which key to trust is the correct fix rather than disabling the check.
printf '%s' "$body" | grep -qiE 'signed-by' \
  || note "the source does not say which key signs it (signed-by)"

pin=/etc/apt/preferences.d/lfcs
if [ ! -f "$pin" ]; then
  note "$pin does not exist"
else
  grep -qE '^[[:space:]]*Package:[[:space:]]*nginx' "$pin" || note "the pin does not name the nginx package"
  grep -qE '^[[:space:]]*Pin:' "$pin" || note "the pin has no Pin: line"
  prio="$(sed -n -E 's/^[[:space:]]*Pin-Priority:[[:space:]]*//p' "$pin" | tail -n1)"
  [ "$prio" = "1001" ] || note "Pin-Priority is '${prio:-unset}', not 1001"
fi
exit "$bad"
