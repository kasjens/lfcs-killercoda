#!/bin/bash
# Step 1: addressing and name resolution. Reads the kernel and the resolver,
# not the config file, so any route to a working address passes.
bad=0
note() { echo "$1" >&2; bad=1; }

ip link show dummy0 >/dev/null 2>&1 || { echo "there is no dummy0 interface" >&2; exit 1; }

ip link show dummy0 | head -n1 | grep -q 'state UP\|,UP' \
  || note "dummy0 exists but is not up"

ip -4 addr show dev dummy0 2>/dev/null | grep -q 'inet 10\.9\.9\.10/24' \
  || note "dummy0 has no 10.9.9.10/24 address"

# IPv6 is half the competency and the half people skip.
ip -6 addr show dev dummy0 2>/dev/null | grep -qi 'inet6 2001:db8::10/64' \
  || note "dummy0 has no 2001:db8::10/64 address"

# Resolution through the switch, so a hosts entry that nsswitch ignores fails.
resolved="$(getent hosts app.lfcs.local 2>/dev/null | awk '{print $1}' | head -n1)"
if [ -z "$resolved" ]; then
  note "app.lfcs.local does not resolve"
elif [ "$resolved" != "10.9.9.10" ]; then
  note "app.lfcs.local resolves to $resolved, not 10.9.9.10"
fi

grep -qE '^[[:space:]]*hosts:' /etc/nsswitch.conf 2>/dev/null \
  || note "/etc/nsswitch.conf has no hosts: line"

exit "$bad"
