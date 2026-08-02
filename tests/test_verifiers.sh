#!/bin/bash
# The verify scripts are the part a learner actually collides with. A verifier
# that rejects a correct answer is worse than no verifier at all.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
pass=0

expect() { # expect <want pass|fail> <label> <script dir> <script> ...
  local want="$1" label="$2" dir="$3" script="$4"
  local got="pass"
  ( cd "$dir" && bash "$script" ) >/dev/null 2>&1 || got="fail"
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1)); printf '  ok    %-46s (%s)\n' "$label" "$got"
  else
    fail=$((fail + 1)); printf '  FAIL  %-46s wanted %s got %s\n' "$label" "$want" "$got"
  fi
}

N=man-pages-navigation
mkdir -p /tmp/answers

record() { printf '%s\n' "$2" > "/tmp/answers/$1"; }

record 1 5;              expect pass "step1 section 5"            "$N" verify1.sh
record 1 8;              expect fail "step1 section 8 rejected"   "$N" verify1.sh
record 2 setquota;       expect pass "step2 setquota"             "$N" verify2.sh
record 2 SetQuota;       expect pass "step2 case insensitive"     "$N" verify2.sh
record 2 edquota;        expect fail "step2 edquota rejected"     "$N" verify2.sh
record 3 noexec;         expect pass "step3 noexec"               "$N" verify3.sh
record 3 nosuid;         expect fail "step3 nosuid rejected"      "$N" verify3.sh
record 4 systemd.exec;   expect pass "step4 systemd.exec"         "$N" verify4.sh
record 4 "systemd.exec(5)"; expect pass "step4 with section"      "$N" verify4.sh
record 4 systemd.service;   expect fail "step4 wrong page"        "$N" verify4.sh

# step 5 compares against `man -w`, so it only runs where nfs(5) exists
nfs_page="$(man -w 5 nfs 2>/dev/null | head -n1)"
case "$nfs_page" in /*) ;; *) nfs_page="" ;; esac
if [ -n "$nfs_page" ] && [ -f "$nfs_page" ]; then
  record 5 "$nfs_page";                  expect pass "step5 path from man -w" "$N" verify5.sh
  record 5 /nope;                        expect fail "step5 wrong path"       "$N" verify5.sh
else
  echo "  skip  step5 (nfs(5) not installed here)"
fi

timer() { sudo mkdir -p /etc/systemd/system 2>/dev/null || mkdir -p /etc/systemd/system
          printf '%s\n' "$1" | sudo tee /etc/systemd/system/hello.timer >/dev/null 2>&1 \
            || printf '%s\n' "$1" > /etc/systemd/system/hello.timer; }

if command -v systemd-analyze >/dev/null 2>&1; then
  timer "[Timer]
OnCalendar=Mon *-*-* 03:00:00
Unit=hello.service";  expect pass "step6 canonical"                "$N" verify6.sh
  timer "[Timer]
OnCalendar=mon *-*-* 03:00
Unit=hello";          expect pass "step6 lowercase + short time"   "$N" verify6.sh
  timer "[Timer]
OnCalendar=Tue *-*-* 03:00:00
Unit=hello.service";  expect fail "step6 wrong day rejected"       "$N" verify6.sh
  timer "[Timer]
OnCalendar=every monday
Unit=hello.service";  expect fail "step6 invalid expression"       "$N" verify6.sh
  timer "[Timer]
OnCalendar=Mon *-*-* 03:00:00"
                      expect fail "step6 missing Unit="            "$N" verify6.sh
  rm -f /etc/systemd/system/hello.timer
else
  echo "  skip  step6 (no systemd-analyze here)"
fi

echo
echo "  $pass passed, $fail failed"
exit "$fail"
