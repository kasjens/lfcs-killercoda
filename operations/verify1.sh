#!/bin/bash
# Step 1: kernel parameters. Both halves: applied now, and written down.
bad=0
note() { echo "$1" >&2; bad=1; }

live="$(sysctl -n net.ipv4.ip_forward 2>/dev/null)"
[ "$live" = "1" ] || note "net.ipv4.ip_forward is '${live:-unreadable}' right now, not 1"

# A drop-in, not an edit of /etc/sysctl.conf, which is package owned.
files=""
for f in /etc/sysctl.d/*.conf; do [ -f "$f" ] && files="$files $f"; done
[ -n "$files" ] || { echo "no drop-in under /etc/sysctl.d" >&2; exit 1; }

get() { # get <key>
  # shellcheck disable=SC2086
  sed -n -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" $files 2>/dev/null | tail -n1
}

fwd="$(get 'net\.ipv4\.ip_forward')"
[ "$fwd" = "1" ] || note "net.ipv4.ip_forward is '${fwd:-unset}' in the drop-in, so it will not survive a reboot"

swap="$(get 'vm\.swappiness')"
[ "$swap" = "10" ] || note "vm.swappiness is '${swap:-unset}' in the drop-in, not 10"

exit "$bad"
