#!/bin/bash
f=/etc/systemd/system/hello.timer
[ -f "$f" ] || { echo "$f does not exist" >&2; exit 1; }

spec="$(sed -n 's/^[[:space:]]*OnCalendar=[[:space:]]*//p' "$f" | head -n1)"
[ -n "$spec" ] || { echo "no OnCalendar= in $f" >&2; exit 1; }

grep -qiE '^[[:space:]]*Unit[[:space:]]*=[[:space:]]*hello(\.service)?[[:space:]]*$' "$f" \
  || { echo "no Unit=hello.service in $f" >&2; exit 1; }

# Prefer systemd's own parser: it accepts every equivalent spelling
# (Mon, monday, Mon *-*-* 03:00, and so on) and normalises them all.
if command -v systemd-analyze >/dev/null 2>&1; then
  norm="$(systemd-analyze calendar "$spec" 2>/dev/null | sed -n 's/^ *Normalized form: *//p')"
  [ -n "$norm" ] || { echo "'$spec' is not a valid calendar expression" >&2; exit 1; }
  echo "$norm" | grep -q 'Mon' || { echo "fires on the wrong day: $norm" >&2; exit 1; }
  echo "$norm" | grep -q '03:00:00' || { echo "fires at the wrong time: $norm" >&2; exit 1; }
  exit 0
fi

# Fallback if systemd-analyze is unavailable.
echo "$spec" | grep -qiE '(^|[ ,])mon' || exit 1
echo "$spec" | grep -qE '03:00(:00)?' || exit 1
