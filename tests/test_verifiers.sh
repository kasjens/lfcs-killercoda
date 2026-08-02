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

# ---------------------------------------------------------------- drill
# The drill verifiers read the round history. They honour LFCS_DRILL_STATE, so
# these run against a scratch directory rather than the learner's real state.

D=man-pages-drill
state="$(mktemp -d)"
export LFCS_DRILL_STATE="$state"

hist() { printf '%s\n' "$1" > "$state/history.json"; }

# round <asked> <notCold json> <review true|false>
round() { printf '{"finished":"2026-01-01T00:00:00+00:00","topic":"ALL",'
          printf '"review":%s,"asked":%s,"planned":%s,"cold":1,"revealed":0,' "$3" "$1" "$1"
          printf '"missed":0,"pct":50,"xp":25,"seconds":60,"notCold":%s}' "$2"; }

rm -f "$state/history.json"
expect fail "drill1 no history yet"            "$D" verify1.sh
hist "[$(round 8 '[]' false)]"
expect pass "drill1 eight item round"          "$D" verify1.sh
expect fail "drill2 eight is not enough"       "$D" verify2.sh
hist "[$(round 20 '[1,2]' false)]"
expect pass "drill2 twenty item round"         "$D" verify2.sh
expect fail "drill3 full round, no repair yet" "$D" verify3.sh
hist "[$(round 20 '[]' false)]"
expect pass "drill3 clean round needs nothing" "$D" verify3.sh
says "nothing needed repairing" "drill3 clean round says so" "$D" verify3.sh
hist "[$(round 20 '[1,2]' false),$(round 2 '[]' true)]"
expect pass "drill3 repair round done"         "$D" verify3.sh

# The three that used to be wrong. A learner who revealed sixteen items gets a
# sixteen-item review round, which the old size-based guess read as the full
# round; and any small round at all counted as the repair.
hist "[$(round 20 '[1,2]' false),$(round 16 '[3]' true)]"
expect pass "drill3 large review still counts" "$D" verify3.sh
hist "[$(round 20 '[1,2]' false),$(round 16 '[]' true)]"
expect pass "drill3 large clean review counts" "$D" verify3.sh
# Exits 0 either way. The old code got here by reading the review round as the
# full round and telling the learner their full round had been clean.
says "Repair round done" "drill3 large clean review, right reason" "$D" verify3.sh
hist "[$(round 20 '[1,2]' false),$(round 3 '[]' false)]"
expect fail "drill3 a small round is no repair" "$D" verify3.sh

echo
echo "  $pass passed, $fail failed"
exit "$fail"
