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

# Some of these pass or fail on the exit code alone but report the wrong thing
# to the learner, which an exit code cannot catch.
says() { # says <substring> <label> <script dir> <script>
  local want="$1" label="$2" dir="$3" script="$4" out
  out="$( cd "$dir" && bash "$script" 2>&1 )"
  case "$out" in
    *"$want"*) pass=$((pass + 1)); printf '  ok    %-46s (%s)\n' "$label" "said so" ;;
    *) fail=$((fail + 1)); printf '  FAIL  %-46s wanted %s in: %s\n' "$label" "$want" "$out" ;;
  esac
}

N=man-pages-navigation
mkdir -p /tmp/answers

record() { printf '%s\n' "$2" > "/tmp/answers/$1"; }
wipe() { rm -f /tmp/answers/*; }

# Each step now verifies a set, so the cases that matter are: the whole set
# right, one member wrong, and one member missing. A step must not pass on a
# partially answered set.

# --- step 1, questions 1 to 3
wipe; record 1 5; record 2 1; record 3 8
expect pass "step1 all three sections"          "$N" verify1.sh
record 2 8
expect fail "step1 chage as 8 rejected"         "$N" verify1.sh
says "question 2" "step1 names the wrong question"  "$N" verify1.sh
record 2 1; rm -f /tmp/answers/3
expect fail "step1 unanswered question fails"   "$N" verify1.sh
says "no answer recorded" "step1 says it is unanswered" "$N" verify1.sh

# --- step 2, questions 4 to 6
wipe; record 4 setquota; record 5 mandb; record 6 manpath
expect pass "step2 all three commands"          "$N" verify2.sh
record 4 SetQuota
expect pass "step2 case insensitive"            "$N" verify2.sh
record 4 edquota
expect fail "step2 edquota rejected"            "$N" verify2.sh

# --- step 3, questions 7 to 9
wipe; record 7 noexec; record 8 nosuid; record 9 G
expect pass "step3 options and pager key"       "$N" verify3.sh
record 9 g
expect fail "step3 lowercase g rejected"        "$N" verify3.sh
record 9 G; record 7 nosuid
expect fail "step3 noexec and nosuid not swappable" "$N" verify3.sh

# The step 3 answers are read out of mount(8), so check the page really says so
# rather than trusting the question. Same rule as everywhere else here: where
# the page is absent this skips and says it skipped.
mount_page="$(man -w 8 mount 2>/dev/null | head -n1)"
case "$mount_page" in /*) ;; *) mount_page="" ;; esac
if [ -n "$mount_page" ] && [ -f "$mount_page" ]; then
  # Counted rather than `grep -q`: -q exits at the first match, zcat dies of
  # SIGPIPE with 141, and pipefail reports the whole pipeline as a failure.
  for opt in noexec nosuid; do
    if [ "$(zcat -f "$mount_page" | grep -c "$opt")" -gt 0 ]; then
      pass=$((pass + 1)); printf '  ok    %-46s (%s)\n' "mount(8) documents $opt" "found"
    else
      fail=$((fail + 1)); printf '  FAIL  %-46s not found in %s\n' "mount(8) documents $opt" "$mount_page"
    fi
  done
else
  echo "  skip  mount(8) content check (page not installed here)"
fi

# --- step 4, questions 10 to 12
wipe; record 10 systemd.exec; record 11 systemd.directives; record 12 7
expect pass "step4 page, index and section"     "$N" verify4.sh
record 10 "systemd.exec(5)"
expect pass "step4 page written with section"   "$N" verify4.sh
record 10 systemd.service
expect fail "step4 systemd.service rejected"    "$N" verify4.sh

# --- step 5, questions 13 to 15
# verify5.sh compares against `man -w`, so it only runs where nfs(5) exists.
nfs_page="$(man -w 5 nfs 2>/dev/null | head -n1)"
case "$nfs_page" in /*) ;; *) nfs_page="" ;; esac
if [ -n "$nfs_page" ] && [ -f "$nfs_page" ]; then
  wipe; record 13 "$nfs_page"; record 14 -w; record 15 -K
  expect pass "step5 path and both flags"       "$N" verify5.sh
  record 14 --where
  expect pass "step5 long form accepted"        "$N" verify5.sh
  record 14 -w; record 15 -k
  expect fail "step5 lowercase -k rejected"     "$N" verify5.sh
  record 15 -K; record 13 /nope
  expect fail "step5 wrong path"                "$N" verify5.sh
else
  echo "  skip  step5 (nfs(5) not installed here)"
fi
wipe

# verify6.sh reads a fixed path, so step 6 has to stage a real unit file there.
# The write used to be attempted with every error discarded, which meant that
# on a box where it could not succeed the three rejection cases still reported
# ok: the file simply never changed. A verifier that was never invoked is not a
# verifier that rejected something. Establish up front that staging works, and
# skip out loud when it does not.
UNIT=/etc/systemd/system/hello.timer
SUDO=""

can_stage() {
  if [ "$(id -u)" -ne 0 ]; then
    sudo -n true 2>/dev/null || return 1
    SUDO="sudo"
  fi
  # Never clobber a real unit file that happens to share the name.
  [ -e "$UNIT" ] && return 2
  $SUDO mkdir -p /etc/systemd/system 2>/dev/null || return 1
  printf 'probe\n' | $SUDO tee "$UNIT" >/dev/null 2>&1 || return 1
  $SUDO rm -f "$UNIT" 2>/dev/null || return 1
  return 0
}

stage() { # stage <unit file text> — preconditions are already checked, so a
          # failure here is real and must stop the run rather than be counted.
  printf '%s\n' "$1" | $SUDO tee "$UNIT" >/dev/null 2>&1 && return 0
  echo "  ERROR could not write $UNIT, step 6 results would be meaningless" >&2
  exit 1
}

# One cleanup for both halves of the file. Single-quoted, so the variables are
# read when the trap fires rather than now: `state` does not exist yet.
trap '[ -n "${staged:-}" ] && $SUDO rm -f "$UNIT"
      [ -n "${state:-}" ] && rm -rf "$state"' EXIT

can_stage; staging=$?

if [ "$staging" -eq 2 ]; then
  echo "  skip  step6 ($UNIT already exists, refusing to overwrite it)"
elif [ "$staging" -ne 0 ]; then
  echo "  skip  step6 (needs root or passwordless sudo to stage $UNIT)"
elif ! command -v systemd-analyze >/dev/null 2>&1; then
  echo "  skip  step6 (no systemd-analyze here)"
else
  staged=1
  timer() { stage "$1"; }
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
  $SUDO rm -f "$UNIT"
  staged=""
fi

# The drill scenario's verifiers are generated from tests/questions.json and
# covered by tests/test_questions.py, so nothing to do here any more. It used
# to read /tmp/lfcs-drill/history.json, which no longer decides anything.

echo
echo "  $pass passed, $fail failed"
exit "$fail"
