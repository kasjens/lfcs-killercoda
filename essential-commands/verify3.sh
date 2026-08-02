#!/bin/bash
# Step 3: performance. Two halves: turn the collector on, and capture a sample.
bad=0
note() { echo "$1" >&2; bad=1; }

# sar reports what a collector already recorded. Installed but disabled is the
# state that makes it look broken, so this is the setting that matters.
if [ ! -f /etc/default/sysstat ]; then
  note "/etc/default/sysstat does not exist, so sysstat is not installed"
else
  enabled="$(sed -n -E 's/^[[:space:]]*ENABLED[[:space:]]*=[[:space:]]*"?([a-zA-Z]+)"?.*/\1/p' \
             /etc/default/sysstat | tail -n1)"
  case "$enabled" in
    true) ;;
    "") note "no ENABLED setting in /etc/default/sysstat" ;;
    *) note "sysstat collection is ENABLED=$enabled, so sar will have nothing to report" ;;
  esac
fi

# The capture. Nothing durable records that you ran vmstat, so this is the one
# place in the domain where the artefact is the evidence.
out=/root/vmstat.txt
if [ ! -s "$out" ]; then
  note "$out is missing or empty"
else
  # vmstat's own column headers, so pasted prose does not pass.
  grep -qE '(^|[[:space:]])(procs|swpd|free|buff|cache)([[:space:]]|$)' "$out" \
    || note "$out does not look like vmstat output"
  # Three samples means at least a header pair plus three data rows.
  rows="$(grep -cE '^[[:space:]]*[0-9]+[[:space:]]+[0-9]+' "$out")"
  [ "${rows:-0}" -ge 3 ] || note "$out has $rows sample rows, fewer than the three asked for"
fi

exit "$bad"
