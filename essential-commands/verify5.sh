#!/bin/bash
# Step 5: disk space. The offender is the large file, and the two small ones
# beside it are there so that deleting the directory does not count as a fix.
bad=0
note() { echo "$1" >&2; bad=1; }
data=/srv/data

[ -d "$data" ] || { echo "$data does not exist" >&2; exit 1; }

[ -e "$data/archive.log" ] && note "$data/archive.log is still there"

for keep in app.log notes.txt; do
  [ -f "$data/$keep" ] || note "$data/$keep was removed; only the oversized file should go"
done

# Truncating rather than deleting also frees the space, so allow it, but the
# file must not still be large.
if [ -f "$data/archive.log" ]; then
  size="$(stat -c %s "$data/archive.log" 2>/dev/null || echo 0)"
  [ "$size" -lt 1048576 ] || note "archive.log is still $size bytes"
fi

exit "$bad"
