#!/bin/bash
# Step 1: LVM. Checks the result, not the device, so it does not matter which
# spare disk you used or in what order you built it.
bad=0
note() { echo "$1" >&2; bad=1; }

command -v vgs >/dev/null 2>&1 || { echo "lvm2 is not installed" >&2; exit 1; }

vgs --noheadings -o vg_name 2>/dev/null | tr -d ' ' | grep -qx datavg \
  || { echo "there is no volume group called datavg" >&2; exit 1; }

if ! lvs --noheadings -o lv_name datavg 2>/dev/null | tr -d ' ' | grep -qx datalv; then
  note "datavg exists but has no logical volume called datalv"
else
  # Size in bytes, so 200M is unambiguous whatever units lvs prefers.
  bytes="$(lvs --noheadings --units b --nosuffix -o lv_size datavg/datalv 2>/dev/null | tr -d ' ')"
  if [ -z "$bytes" ]; then
    note "could not read the size of datavg/datalv"
  elif [ "$bytes" -lt 200000000 ]; then
    note "datavg/datalv is $((bytes / 1024 / 1024))M, smaller than the 200M asked for"
  fi

  fstype="$(blkid -o value -s TYPE /dev/datavg/datalv 2>/dev/null)"
  [ "$fstype" = "ext4" ] || note "datavg/datalv holds '${fstype:-no filesystem}', not ext4"
fi

# Mounted where it was asked for, read from the kernel rather than from fstab.
if ! findmnt -n /srv/lv >/dev/null 2>&1; then
  note "nothing is mounted at /srv/lv"
else
  src="$(findmnt -n -o SOURCE /srv/lv 2>/dev/null)"
  # Covers both spellings the kernel may report, /dev/datavg/datalv and
  # /dev/mapper/datavg-datalv.
  case "$src" in
    *datavg*datalv*) ;;
    *) note "/srv/lv is mounted from $src, not from the logical volume" ;;
  esac
fi

exit "$bad"
