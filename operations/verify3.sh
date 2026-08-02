#!/bin/bash
# Step 3: scheduled jobs, both mechanisms.
bad=0
note() { echo "$1" >&2; bad=1; }

# --- cron. A file in /etc/cron.d has a user field that a user crontab does not.
cd=/etc/cron.d/lfcs
if [ ! -f "$cd" ]; then
  note "$cd does not exist"
else
  line="$(grep -vE '^[[:space:]]*(#|$)' "$cd" | grep -v '^[A-Z_]*=' | tail -n1)"
  if [ -z "$line" ]; then
    note "$cd has no job line"
  else
    min="$(printf '%s' "$line" | awk '{print $1}')"
    hour="$(printf '%s' "$line" | awk '{print $2}')"
    user="$(printf '%s' "$line" | awk '{print $6}')"
    [ "$min" = "30" ] || note "the cron minute field is '$min', not 30"
    [ "$hour" = "2" ] || note "the cron hour field is '$hour', not 2"
    [ "$user" = "root" ] || note "the sixth field is '$user'; /etc/cron.d needs a user there"
    printf '%s' "$line" | grep -q '/usr/local/bin/report.sh' \
      || note "the cron job does not run /usr/local/bin/report.sh"
  fi
fi

# --- the timer, which needs a service of the same name to activate.
t=/etc/systemd/system/lfcs-report.timer
s=/etc/systemd/system/lfcs-report.service
[ -f "$t" ] || note "$t does not exist"
[ -f "$s" ] || note "$s does not exist: a timer with no matching service activates nothing"

if [ -f "$t" ]; then
  oncal="$(sed -n -E 's/^[[:space:]]*OnCalendar[[:space:]]*=[[:space:]]*//p' "$t" | tail -n1)"
  [ -n "$oncal" ] || note "the timer has no OnCalendar="
  if [ -n "$oncal" ] && command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze calendar "$oncal" >/dev/null 2>&1 \
      || note "'$oncal' is not a valid calendar expression"
  fi
  grep -qE '^[[:space:]]*\[Install\]' "$t" || note "the timer has no [Install] section, so it cannot be enabled"
fi
exit "$bad"
