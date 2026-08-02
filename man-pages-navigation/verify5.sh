#!/bin/bash
# Questions 13 to 15: where a page lives, and the two flags that get you there.
bad=0

check() { # check <n> <cs|ci> <subject> <accepted answer>...
  local n="$1" mode="$2" subject="$3" a want; shift 3
  a="$(tr -d '[:space:]' < "/tmp/answers/$n" 2>/dev/null)"
  [ "$mode" = ci ] && a="${a,,}"
  [ -n "$a" ] || { echo "question $n ($subject) has no answer recorded" >&2; bad=1; return; }
  for want in "$@"; do
    [ "$mode" = ci ] && want="${want,,}"
    [ "$a" = "$want" ] && return
  done
  echo "question $n ($subject) is not right yet" >&2
  bad=1
}

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

check 13 cs "the full path of the nfs(5) source file" "$want"
# Flags are case-sensitive in real life, and -k against -K is the whole point.
check 14 cs "the man flag that prints a page's path" -w --where
check 15 cs "the man flag that searches the body of every page" -K --global-apropos

exit "$bad"
