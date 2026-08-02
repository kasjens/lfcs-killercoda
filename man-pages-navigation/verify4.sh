#!/bin/bash
# Questions 10 to 12: which page owns a directive, and the index that says so.
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

# systemd.exec(5), not systemd.service(5). Accept the common spellings.
check 10 ci "the page defining WorkingDirectory=" \
  systemd.exec "systemd.exec(5)" systemd.exec.5 man5systemd.exec
check 11 ci "the page indexing every directive to its own page" \
  systemd.directives "systemd.directives(7)" systemd.directives.7 man7systemd.directives
check 12 ci "the section systemd.directives lives in" 7

exit "$bad"
