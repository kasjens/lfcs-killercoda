#!/bin/bash
# Step 6: the automounter. Two files, and the one that fails silently is the
# map, so check both.
bad=0
note() { echo "$1" >&2; bad=1; }

# The master map may be the file itself or a drop-in beside it.
masters="/etc/auto.master"
for f in /etc/auto.master.d/*; do
  [ -f "$f" ] && masters="$masters $f"
done

# shellcheck disable=SC2086
entry="$(grep -hE '^[[:space:]]*/data[[:space:]]' $masters 2>/dev/null | tail -n1)"
if [ -z "$entry" ]; then
  note "no automounter entry for /data in auto.master or auto.master.d"
else
  mapfile_path="$(printf '%s' "$entry" | awk '{print $2}')"
  if [ -z "$mapfile_path" ]; then
    note "the /data entry names no map file"
  elif [ ! -f "$mapfile_path" ]; then
    note "the /data entry points at $mapfile_path, which does not exist"
  else
    # The key is the subdirectory under /data, so /data/backup means key backup.
    key="$(grep -E '^[[:space:]]*backup[[:space:]]' "$mapfile_path" 2>/dev/null | tail -n1)"
    if [ -z "$key" ]; then
      note "$mapfile_path has no entry for backup"
    else
      printf '%s' "$key" | grep -qE ':' \
        || note "the backup entry in $mapfile_path names no location to mount"
    fi
  fi
fi

exit "$bad"
