#!/bin/bash
# Questions 1 to 3: sections. The whole set has to be right, and each wrong
# answer is named so the learner knows which one to go back to.
#
# The check helper is repeated in each verifier on purpose. Killercoda only
# promises the verify script named in index.json is on the host, so sourcing a
# shared sibling is not safe.
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

# 5 is file formats, 1 is user commands, 8 is system administration.
check 1 ci "the section documenting the format of /etc/fstab" 5
check 2 ci "the section chage lives in" 1
check 3 ci "the section of the sysctl you run to change a parameter" 8

exit "$bad"
