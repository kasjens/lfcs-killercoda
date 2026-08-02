#!/bin/bash
# Step 3: resource limits. limits.conf or a drop-in under limits.d both count,
# because both are how pam_limits reads it.
bad=0
note() { echo "$1" >&2; bad=1; }

files="/etc/security/limits.conf"
for f in /etc/security/limits.d/*.conf; do
  [ -e "$f" ] && files="$files $f"
done

# <domain> <type> <item> <value>, whitespace separated, comments ignored.
find_limit() { # find_limit <type> <item>
  # shellcheck disable=SC2086
  awk -v t="$1" -v i="$2" '
    /^[[:space:]]*#/ { next }
    $1 == "deploy" && $2 == t && $3 == i { print $4; found=1 }
    END { if (!found) print "" }
  ' $files 2>/dev/null | grep -v '^$' | tail -n1
}

soft="$(find_limit soft nofile)"
hard="$(find_limit hard nofile)"

[ -n "$soft" ] || note "no soft nofile limit for deploy in limits.conf or limits.d"
[ -n "$hard" ] || note "no hard nofile limit for deploy in limits.conf or limits.d"
[ -z "$soft" ] || [ "$soft" = "4096" ] || note "deploy's soft nofile is $soft, not 4096"
[ -z "$hard" ] || [ "$hard" = "8192" ] || note "deploy's hard nofile is $hard, not 8192"

# A soft limit above the hard one is rejected at login, so it is worth catching
# here rather than letting it look configured.
if [ -n "$soft" ] && [ -n "$hard" ] && [ "$soft" -gt "$hard" ] 2>/dev/null; then
  note "the soft limit is above the hard limit, which cannot take effect"
fi

exit "$bad"
