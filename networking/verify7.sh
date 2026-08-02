#!/bin/bash
# Step 7: bridge and bonding. Both are about enslaving interfaces to a virtual
# one, so the check is that the members really are enslaved.
bad=0
note() { echo "$1" >&2; bad=1; }

# --- bridge
if ! ip link show br0 >/dev/null 2>&1; then
  note "there is no br0 interface"
else
  ip -d link show br0 2>/dev/null | grep -q 'bridge' \
    || note "br0 exists but is not a bridge"
  master="$(ip -o link show dummy1 2>/dev/null | grep -o 'master [^ ]*' | awk '{print $2}')"
  [ "$master" = "br0" ] \
    || note "dummy1 is not enslaved to br0 (master is '${master:-none}')"
fi

# --- bond
if ! ip link show bond0 >/dev/null 2>&1; then
  note "there is no bond0 interface"
else
  detail="$(ip -d link show bond0 2>/dev/null)"
  printf '%s' "$detail" | grep -q 'bond' || note "bond0 exists but is not a bond"
  # active-backup is the mode that needs no switch cooperation, which is why
  # it is the one to reach for when you cannot configure the other end.
  printf '%s' "$detail" | grep -q 'mode active-backup' \
    || note "bond0 is not in active-backup mode"
  master="$(ip -o link show dummy2 2>/dev/null | grep -o 'master [^ ]*' | awk '{print $2}')"
  [ "$master" = "bond0" ] \
    || note "dummy2 is not enslaved to bond0 (master is '${master:-none}')"
fi

exit "$bad"
