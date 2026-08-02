#!/bin/bash
# Step 7: storage performance. Nothing durable records that you measured, so
# the captured report is the evidence. It is checked for shape, not just size.
bad=0
note() { echo "$1" >&2; bad=1; }
out=/root/iostat.txt

[ -s "$out" ] || { echo "$out is missing or empty" >&2; exit 1; }

# iostat's device table header. -x is what adds the extended columns, and
# without it the report cannot answer the question the step asks.
grep -qE '^Device' "$out" || note "$out has no Device table: is this iostat output?"

grep -qE '%util|aqu-sz|await' "$out" \
  || note "$out has no extended columns, so it was not run with -x"

# At least two reports, meaning an interval was given rather than one snapshot
# averaged since boot.
reports="$(grep -cE '^Device' "$out")"
[ "${reports:-0}" -ge 2 ] \
  || note "$out contains $reports report(s); a single one is an average since boot, not a measurement"

exit "$bad"
