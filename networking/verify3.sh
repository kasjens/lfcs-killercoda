#!/bin/bash
# Step 3: monitoring. Nothing durable records that you looked, so the captured
# report is the evidence, and it is checked for the flags that make it useful.
bad=0
note() { echo "$1" >&2; bad=1; }
out=/root/sockets.txt

[ -s "$out" ] || { echo "$out is missing or empty" >&2; exit 1; }

# ss prints this header for -t/-u listings whatever else is asked for.
grep -qE 'State|Netid' "$out" || note "$out does not look like ss output"

# Numeric, or the report resolves names and hides which port is which.
if grep -qE '(^|[[:space:]])(ssh|http|domain)([[:space:]]|$)' "$out"; then
  note "$out shows service names, so it was not captured with -n"
fi

# Listening sockets specifically, not every connection.
grep -qiE 'LISTEN|UNCONN' "$out" \
  || note "$out has no listening sockets, so -l was probably missing"

exit "$bad"
