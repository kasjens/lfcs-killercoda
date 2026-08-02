#!/bin/bash
# Questions 4 to 6: three commands recovered from their descriptions alone.
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

# setquota sets limits from the command line; edquota opens an editor.
check 4 ci "the command that sets a quota limit without an editor" setquota
check 5 ci "the command that builds the index apropos reads" mandb
check 6 ci "the command that prints where man looks for pages" manpath

exit "$bad"
