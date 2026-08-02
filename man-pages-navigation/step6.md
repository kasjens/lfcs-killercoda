# Now use it for real

No recording this time. Build the thing.

### Task

Create `/etc/systemd/system/hello.timer` that fires **every Monday at 03:00**
and triggers `hello.service`.

You will need three things, and they are on three different pages:

- the `[Timer]` section and `OnCalendar=` — `systemd.timer(5)`
- the calendar grammar itself — **not** on the timer page
- `Unit=` — also `systemd.timer(5)`

The second one is the point of the exercise. `systemd.timer(5)` tells you
`OnCalendar=` exists and then hands the syntax to another page. Find it.

```
vim /etc/systemd/system/hello.timer
```{{exec}}

Check your expression before you commit to it:

```
systemd-analyze calendar 'Mon *-*-* 03:00:00'
```{{exec}}

<details><summary>Tip</summary>

Anything in systemd that smells like a date or a duration is documented in
`systemd.time(7)` — a 7, because it describes a syntax rather than a file. Same
page answers `journalctl --since` and `RestartSec=`.

```
man 7 systemd.time
```{{exec}}

</details>

<details><summary>Solution</summary>

```
[Unit]
Description=hello

[Timer]
OnCalendar=Mon *-*-* 03:00:00
Unit=hello.service

[Install]
WantedBy=timers.target
```{{copy}}

</details>
