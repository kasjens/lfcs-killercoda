#!/bin/bash
# Step 1: accounts. Checks the box, not a typed answer, so any route that
# produces the right result passes.
bad=0
note() { echo "$1" >&2; bad=1; }

# --- the group
if ! getent group webops >/dev/null; then
  note "there is no webops group yet"
else
  gid="$(getent group webops | cut -d: -f3)"
  [ "$gid" = "4000" ] || note "webops exists but its GID is $gid, not 4000"
fi

# --- the account
if ! getent passwd deploy >/dev/null; then
  note "there is no deploy account yet"
else
  entry="$(getent passwd deploy)"
  home="$(printf '%s' "$entry" | cut -d: -f6)"
  shell="$(printf '%s' "$entry" | cut -d: -f7)"
  [ "$home" = "/home/deploy" ] || note "deploy's home is $home, not /home/deploy"
  [ "$shell" = "/bin/bash" ] || note "deploy's login shell is $shell, not /bin/bash"
  [ -d "$home" ] || note "$home is in the passwd entry but does not exist on disk"
  primary="$(id -gn deploy 2>/dev/null)"
  [ "$primary" = "webops" ] || note "deploy's primary group is $primary, not webops"

  # Expiry lives in shadow, not passwd, which is the point of asking for it.
  expiry="$(chage -l deploy 2>/dev/null | sed -n 's/^Account expires[[:space:]]*:[[:space:]]*//p')"
  case "$expiry" in
    *"Dec 31, 2026"*|*"31 Dec 2026"*|*"2026-12-31"*) ;;
    ""|*never*) note "deploy has no account expiry set" ;;
    *) note "deploy expires $expiry, not 31 December 2026" ;;
  esac
fi

exit "$bad"
