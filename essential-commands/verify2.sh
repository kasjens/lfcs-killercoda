#!/bin/bash
# Step 2: services. Checks the unit on disk and that it is enabled, which is a
# symlink either way, so this works whether or not systemd is running.
bad=0
note() { echo "$1" >&2; bad=1; }
unit=/etc/systemd/system/hello.service

[ -f "$unit" ] || { echo "$unit does not exist yet" >&2; exit 1; }

# Directive lookup that ignores comments and leading whitespace.
d() { sed -n -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" "$unit" | tail -n1; }

[ -n "$(d Description)" ] || note "the unit has no Description="

exec_start="$(d ExecStart)"
[ -n "$exec_start" ] || note "the unit has no ExecStart="

restart="$(d Restart)"
[ "$restart" = "on-failure" ] || note "Restart= is '${restart:-unset}', not on-failure"

user="$(d User)"
[ "$user" = "deploy" ] || note "User= is '${user:-unset}', not deploy"

wd="$(d WorkingDirectory)"
[ "$wd" = "/srv/app" ] || note "WorkingDirectory= is '${wd:-unset}', not /srv/app"

grep -qE '^[[:space:]]*\[Install\]' "$unit" \
  || note "the unit has no [Install] section, so it cannot be enabled"

# `systemctl enable` is exactly this symlink, so checking for it works on a box
# where systemd is not running the show.
if ! find /etc/systemd/system -name hello.service -type l 2>/dev/null | grep -q .; then
  note "hello.service is not enabled: no wants symlink points at it"
fi

exit "$bad"
