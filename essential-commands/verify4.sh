#!/bin/bash
# Step 4: constraints. A drop-in, not an edit of the unit, and the directives
# have to be the systemd ones rather than the PAM ones.
bad=0
note() { echo "$1" >&2; bad=1; }
dir=/etc/systemd/system/hello.service.d

if [ ! -d "$dir" ]; then
  echo "$dir does not exist: the limits belong in a drop-in, not in the unit" >&2
  exit 1
fi

conf="$(cat "$dir"/*.conf 2>/dev/null)"
[ -n "$conf" ] || { echo "no .conf file in $dir" >&2; exit 1; }

get() { printf '%s\n' "$conf" | sed -n -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" | tail -n1; }

printf '%s\n' "$conf" | grep -qE '^[[:space:]]*\[Service\]' \
  || note "the drop-in has no [Service] section, so its directives are ignored"

mem="$(get MemoryMax)"
case "$mem" in
  512M|512m) ;;
  "") note "MemoryMax= is not set in the drop-in" ;;
  *) note "MemoryMax= is $mem, not 512M" ;;
esac

cpu="$(get CPUQuota)"
case "$cpu" in
  20%) ;;
  "") note "CPUQuota= is not set in the drop-in" ;;
  *) note "CPUQuota= is $cpu, not 20%" ;;
esac

# The unit itself must be left alone: the point of a drop-in is not editing it.
if grep -qE '^[[:space:]]*(MemoryMax|CPUQuota)[[:space:]]*=' \
     /etc/systemd/system/hello.service 2>/dev/null; then
  note "the limits are also in hello.service itself; put them only in the drop-in"
fi

exit "$bad"
