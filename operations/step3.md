# Manage or schedule jobs for executing commands

Two mechanisms, and the exam can ask for either.

**cron** has five time fields: minute, hour, day of month, month, day of week.
The trap is `/etc/cron.d`: files there take a **sixth field, the user**, before
the command. A user's own crontab does not, because the user is implied. Paste
a personal crontab line into `/etc/cron.d` and the command silently becomes the
username, and nothing runs.

The five-field format is documented in `crontab(5)`, not `crontab(1)`. Same
name, two sections: the command that edits, and the file that describes.

**systemd timers** are two units. A `.timer` says when, a `.service` says what.
By default a timer activates the service of the same name, so `lfcs-report.timer`
looks for `lfcs-report.service` and does nothing if it is missing. `Unit=` in
the `[Timer]` section overrides that pairing.

The `OnCalendar=` grammar is in `systemd.time(7)`, not `systemd.timer(5)`. A 7
because it describes a syntax rather than a file, and the same page covers
`journalctl --since`. `systemd-analyze calendar '<expr>'` tells you what an
expression means and when it fires next, which beats waiting to find out.

Timers over cron when you want a job that catches up after downtime
(`Persistent=true`), or that depends on other units. cron when you want the
thing everyone can read at a glance.

### Task

Schedule `/usr/local/bin/report.sh`, which already exists, **twice**:

1. With cron, at **02:30 daily**, as **root**, in `/etc/cron.d/lfcs`.
2. With systemd: `lfcs-report.service` that runs it, and `lfcs-report.timer`
   with **`OnCalendar=daily`** and an `[Install]` section.

<details><summary>Tip</summary>

```
man 5 crontab
man 5 systemd.timer
man 7 systemd.time
```{{exec}}

Check your calendar expression before committing to it:

```
systemd-analyze calendar daily
```{{exec}}

</details>

<details><summary>Solution</summary>

```
printf '30 2 * * * root /usr/local/bin/report.sh\n' > /etc/cron.d/lfcs
printf '[Unit]\nDescription=report\n\n[Service]\nType=oneshot\nExecStart=/usr/local/bin/report.sh\n' > /etc/systemd/system/lfcs-report.service
printf '[Unit]\nDescription=report timer\n\n[Timer]\nOnCalendar=daily\nUnit=lfcs-report.service\n\n[Install]\nWantedBy=timers.target\n' > /etc/systemd/system/lfcs-report.timer
systemctl daemon-reload
```{{copy}}

</details>
