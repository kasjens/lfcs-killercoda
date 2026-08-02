#!/bin/bash
# Compare against what man itself reports rather than a hardcoded path, so this
# keeps working across package versions.
#
# Guard against the minimized-Ubuntu stub: on those images /usr/bin/man is a
# shell script that prints "This system has been minimized" and exits 0, so a
# plain non-empty check would happily compare against that message.
want="$(man -w 5 nfs 2>/dev/null | head -n1)"
case "$want" in
  /*) ;;
  *) echo "nfs(5) is not available yet — man pages may still be installing" >&2
     exit 1 ;;
esac
[ -f "$want" ] || { echo "man reported $want but it is not a file" >&2; exit 1; }

got="$(tr -d '[:space:]' < /tmp/answers/5 2>/dev/null)"
[ "$got" = "$want" ]
