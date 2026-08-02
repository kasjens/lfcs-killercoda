#!/bin/bash
# Step 3: filesystems. Label, mount, and an fstab entry by UUID rather than by
# device name, which is the part that actually matters.
bad=0
note() { echo "$1" >&2; bad=1; }
mp=/srv/disk

if ! findmnt -n "$mp" >/dev/null 2>&1; then
  echo "nothing is mounted at $mp" >&2
  exit 1
fi

src="$(findmnt -n -o SOURCE "$mp" 2>/dev/null)"
fstype="$(findmnt -n -o FSTYPE "$mp" 2>/dev/null)"
[ "$fstype" = "ext4" ] || note "$mp is $fstype, not ext4"

label="$(blkid -o value -s LABEL "$src" 2>/dev/null)"
[ "$label" = "DATA" ] || note "the filesystem label is '${label:-unset}', not DATA"

uuid="$(blkid -o value -s UUID "$src" 2>/dev/null)"
[ -n "$uuid" ] || note "could not read a UUID from $src"

line="$(grep -E "^[^#]*[[:space:]]${mp}[[:space:]]" /etc/fstab 2>/dev/null | tail -n1)"
if [ -z "$line" ]; then
  note "no /etc/fstab entry for $mp"
else
  first="$(printf '%s' "$line" | awk '{print $1}')"
  case "$first" in
    UUID=*)
      want="${first#UUID=}"
      want="${want%\"}"; want="${want#\"}"
      [ -n "$uuid" ] && [ "$want" != "$uuid" ] \
        && note "the fstab entry uses UUID $want but the filesystem is $uuid"
      ;;
    LABEL=*)
      note "the fstab entry uses a label; the task asks for the UUID" ;;
    /dev/*)
      note "the fstab entry names $first directly; device names can change between boots, use the UUID" ;;
    *)
      note "the fstab entry starts with '$first', which is neither a UUID nor a device" ;;
  esac
fi

exit "$bad"
