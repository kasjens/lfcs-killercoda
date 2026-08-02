#!/bin/bash
# Step 5: swap. Checks the signature on the file rather than whether it is
# currently active, because activating swap is kernel-wide and this box shares
# it. The fstab entry is what makes it permanent either way.
bad=0
note() { echo "$1" >&2; bad=1; }
sw=/srv/swapfile

[ -f "$sw" ] || { echo "$sw does not exist" >&2; exit 1; }

size="$(stat -c %s "$sw" 2>/dev/null || echo 0)"
[ "$size" -ge 268435456 ] || note "$sw is $((size / 1024 / 1024))M, smaller than the 256M asked for"

# mkswap writes a signature. Without it swapon refuses, however big the file.
type="$(blkid -o value -s TYPE "$sw" 2>/dev/null)"
[ "$type" = "swap" ] || note "$sw has no swap signature: mkswap has not been run on it"

# A world-readable swap file exposes whatever the kernel paged out of memory.
perms="$(stat -c %a "$sw" 2>/dev/null)"
[ "$perms" = "600" ] || note "$sw is mode $perms, which should be 600"

line="$(grep -E "^[^#]*[[:space:]]swap[[:space:]]" /etc/fstab 2>/dev/null | grep -F "$sw" | tail -n1)"
if [ -z "$line" ]; then
  note "no /etc/fstab entry making $sw swap at boot"
else
  printf '%s' "$line" | awk '{print $3}' | grep -qx swap \
    || note "the fstab entry for $sw is not type swap"
  # Column two is meaningless for swap, and "none" is the convention.
  mnt="$(printf '%s' "$line" | awk '{print $2}')"
  case "$mnt" in
    none|swap) ;;
    *) note "the fstab mount point column says '$mnt'; swap has no mount point, use none" ;;
  esac
fi

exit "$bad"
