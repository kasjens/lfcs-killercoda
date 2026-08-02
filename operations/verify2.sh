#!/bin/bash
# Step 2: a broken unit. The two faults are a mistyped section header, which
# makes systemd ignore every directive under it, and an ExecStart pointing at
# something that does not exist.
bad=0
note() { echo "$1" >&2; bad=1; }
unit=/etc/systemd/system/broken.service

[ -f "$unit" ] || { echo "$unit does not exist" >&2; exit 1; }

grep -qE '^[[:space:]]*\[Service\][[:space:]]*$' "$unit" \
  || note "there is no [Service] section; check the spelling of the section header"

grep -qE '^[[:space:]]*\[Unit\][[:space:]]*$' "$unit" \
  || note "there is no [Unit] section"

exec_line="$(sed -n -E 's/^[[:space:]]*ExecStart[[:space:]]*=[[:space:]]*//p' "$unit" | tail -n1)"
if [ -z "$exec_line" ]; then
  note "the unit has no ExecStart="
else
  # Strip any leading modifier characters systemd allows, then take argv[0].
  cmd="$(printf '%s' "$exec_line" | sed -E 's/^[-+!@]+//' | awk '{print $1}')"
  case "$cmd" in
    /*) [ -x "$cmd" ] || note "ExecStart runs $cmd, which does not exist or is not executable" ;;
    *) note "ExecStart must be an absolute path, but it starts with '$cmd'" ;;
  esac
fi
exit "$bad"
