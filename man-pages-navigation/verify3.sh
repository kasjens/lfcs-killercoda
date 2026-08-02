#!/bin/bash
# Questions 7 to 9: two options out of mount(8), one pager key.
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

check 7 ci "the mount option that blocks running binaries" noexec
check 8 ci "the mount option that disables set-user-ID bits" nosuid
# g and G differ only by case, which is the whole point of the question.
check 9 cs "the pager key that jumps to the end of a page" G

exit "$bad"
