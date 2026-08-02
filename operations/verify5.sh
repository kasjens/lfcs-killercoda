#!/bin/bash
# Step 5: recovering from a boot-blocking fstab. The entry must survive a
# missing device rather than being deleted outright.
bad=0
note() { echo "$1" >&2; bad=1; }

line="$(grep -E "^[^#]*[[:space:]]/mnt/backup[[:space:]]" /etc/fstab 2>/dev/null | tail -n1)"
if [ -z "$line" ]; then
  note "the /mnt/backup entry is gone; the task is to make it survive a missing device, not to delete it"
else
  opts="$(printf '%s' "$line" | awk '{print $4}')"
  # nofail is what turns "boot hangs waiting for a device" into "carry on".
  printf '%s' "$opts" | grep -q 'nofail' \
    || note "the /mnt/backup entry still has no nofail, so a missing device blocks boot"
  # Column six decides fsck order; a non-zero value on an absent device is the
  # other half of the same hang.
  pass="$(printf '%s' "$line" | awk '{print $6}')"
  case "$pass" in
    0) ;;
    "") note "the entry has no fsck pass column" ;;
    *) note "the fsck pass column is $pass; an unavailable device should be 0" ;;
  esac
fi

# The root entry must not have been collateral damage.
grep -qE "^[^#]*[[:space:]]/[[:space:]]" /etc/fstab 2>/dev/null \
  || note "there is no root filesystem entry left in /etc/fstab"

# findmnt --verify also reports unreachable devices, which is exactly the
# situation this task makes survivable, so those are expected. Only parse
# errors mean the file itself is malformed.
if command -v findmnt >/dev/null 2>&1; then
  out="$(findmnt --verify --tab-file /etc/fstab 2>&1)"
  parse="$(printf '%s' "$out" | sed -n -E 's/^([0-9]+) parse errors.*/\1/p' | tail -n1)"
  [ "${parse:-0}" -eq 0 ] 2>/dev/null \
    || note "findmnt reports $parse parse error(s) in /etc/fstab"
fi
exit "$bad"
