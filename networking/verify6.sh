#!/bin/bash
# Step 6: static routing. Reads the kernel routing table.
bad=0
note() { echo "$1" >&2; bad=1; }

routes="$(ip route show 2>/dev/null)"
routes6="$(ip -6 route show 2>/dev/null)"

# The specific route, with the right next hop and interface.
line="$(printf '%s\n' "$routes" | grep -E '^192\.0\.2\.0/24' | head -n1)"
if [ -z "$line" ]; then
  note "there is no route for 192.0.2.0/24"
else
  printf '%s' "$line" | grep -q 'via 10.9.9.254' \
    || note "the 192.0.2.0/24 route does not go via 10.9.9.254"
  printf '%s' "$line" | grep -q 'dev dummy0' \
    || note "the 192.0.2.0/24 route is not on dummy0"
fi

# An unreachable route is how you black-hole a range deliberately rather than
# letting it follow the default route out.
printf '%s\n' "$routes" | grep -qE '^(unreachable|blackhole) 198\.51\.100\.0/24' \
  || note "198.51.100.0/24 is not blackholed or unreachable"

printf '%s\n' "$routes6" | grep -qiE '^2001:db8:beef::/48' \
  || note "there is no IPv6 route for 2001:db8:beef::/48"

exit "$bad"
