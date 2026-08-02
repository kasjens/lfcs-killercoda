#!/bin/bash
# Step 4: OpenSSH. Reads the effective settings, and lets sshd judge its own
# file where the binary is available.
bad=0
note() { echo "$1" >&2; bad=1; }
conf=/etc/ssh/sshd_config

[ -f "$conf" ] || { echo "$conf does not exist" >&2; exit 1; }

# Directives are case-insensitive and first-match-wins in sshd, so read the
# first uncommented occurrence rather than the last.
get() {
  grep -hiE "^[[:space:]]*$1[[:space:]]+" "$conf" /etc/ssh/sshd_config.d/*.conf 2>/dev/null \
    | head -n1 | awk '{print $2}'
}

port="$(get Port)"
[ "$port" = "2222" ] || note "Port is '${port:-unset}', not 2222"

root="$(get PermitRootLogin)"
case "$root" in
  no) ;;
  "") note "PermitRootLogin is not set; the default permits key-based root login" ;;
  *) note "PermitRootLogin is '$root', not no" ;;
esac

pw="$(get PasswordAuthentication)"
case "$pw" in
  no) ;;
  "") note "PasswordAuthentication is not set" ;;
  *) note "PasswordAuthentication is '$pw', not no" ;;
esac

# The config is only correct if sshd itself accepts it.
if command -v sshd >/dev/null 2>&1; then
  sshd -t -f "$conf" >/dev/null 2>&1 || note "sshd rejects $conf as invalid"
fi

exit "$bad"
