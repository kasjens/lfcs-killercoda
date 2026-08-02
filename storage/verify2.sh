#!/bin/bash
# Step 2: the virtual filesystem. A tmpfs that is both mounted now and written
# down for next boot, which are two different things.
bad=0
note() { echo "$1" >&2; bad=1; }
mp=/srv/cache

# Mounted now, according to the kernel.
if ! findmnt -n "$mp" >/dev/null 2>&1; then
  note "nothing is mounted at $mp"
else
  fstype="$(findmnt -n -o FSTYPE "$mp" 2>/dev/null)"
  [ "$fstype" = "tmpfs" ] || note "$mp is $fstype, not tmpfs"

  opts="$(findmnt -n -o OPTIONS "$mp" 2>/dev/null)"
  case "$opts" in
    *size=65536k*|*size=64M*|*size=64m*) ;;
    *) note "the mounted tmpfs has options '$opts', without a 64M size limit" ;;
  esac
fi

# Written down, so it survives a reboot. A mount that is not in fstab is a
# mount you lose.
line="$(grep -E "^[^#]*[[:space:]]$mp[[:space:]]" /etc/fstab 2>/dev/null | tail -n1)"
if [ -z "$line" ]; then
  note "no /etc/fstab entry for $mp"
else
  printf '%s' "$line" | awk '{print $3}' | grep -qx tmpfs \
    || note "the fstab entry for $mp is not type tmpfs"
  printf '%s' "$line" | grep -qE 'size=(64M|64m|65536k)' \
    || note "the fstab entry for $mp has no 64M size option"
fi

exit "$bad"
