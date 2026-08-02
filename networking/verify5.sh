#!/bin/bash
# Step 5: packet filtering and NAT. Reads the live ruleset from the kernel, so
# a rules file that was never loaded does not pass.
bad=0
note() { echo "$1" >&2; bad=1; }

command -v nft >/dev/null 2>&1 || { echo "nft is not installed" >&2; exit 1; }

rules="$(nft list ruleset 2>/dev/null)"
[ -n "$rules" ] || { echo "the nftables ruleset is empty" >&2; exit 1; }

# A filter chain that drops by default. Anything else is a firewall in name only.
printf '%s\n' "$rules" | grep -qE 'type filter hook input' \
  || note "no input filter chain"
printf '%s\n' "$rules" | grep -E 'type filter hook input' | grep -q 'policy drop' \
  || note "the input chain does not have policy drop"

# Without this, dropping by default also drops the replies to your own traffic.
printf '%s\n' "$rules" | grep -qE 'ct state.*(established|related)' \
  || note "nothing accepts established and related connections, so replies are dropped too"

# Locked out is the classic self-inflicted wound.
printf '%s\n' "$rules" | grep -qE 'dport (22|ssh)' \
  || note "nothing accepts ssh, which would lock you out of a real box"

# Loopback traffic is not optional; plenty of services talk to themselves.
printf '%s\n' "$rules" | grep -qE 'iif(name)? "?lo"?' \
  || note "loopback traffic is not accepted"

# NAT, in the right hook.
printf '%s\n' "$rules" | grep -qE 'type nat hook postrouting' \
  || note "no nat postrouting chain"
printf '%s\n' "$rules" | grep -q 'masquerade' \
  || note "no masquerade rule, so nothing is translated"

exit "$bad"
