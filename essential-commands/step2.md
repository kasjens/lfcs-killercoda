# Create, configure and troubleshoot services

A unit is a file, and its directives are documented across several pages rather
than one. `systemd.service(5)`{{}} owns the service-specific directives:
`Type=`{{}}, `ExecStart=`{{}}, `Restart=`{{}}. The execution environment was
factored out into `systemd.exec(5)`{{}}, because sockets and mounts need it
too. So `User=`{{}}, `WorkingDirectory=`{{}} and `Environment=`{{}} are **not**
on the page you would guess, and looking on the wrong one costs a minute every
time.

`systemd.directives(7)`{{}} is the index that settles it: every directive
against the page that defines it.

Three structural things the exam expects you to know.

**`[Install]`{{}} is what makes a unit enableable.** Without it,
`systemctl enable`{{}} has nothing to act on and fails. The section names the
target that should want this unit.

**Enabling is a symlink, not a flag.** `systemctl enable`{{}} creates a symlink
from the target's `.wants`{{}} directory to your unit file. Nothing else. That
is why `systemctl enable`{{}} and `systemctl start`{{}} are separate: one
arranges for boot, the other acts now.

**systemd caches units in memory.** Editing a file on disk changes nothing
until `systemctl daemon-reload`{{}}. Forgetting that is the usual reason a
correct fix appears not to work.

### Task

Create **`/etc/systemd/system/hello.service`{{}}**:

1. A `Description=`{{}}.
2. `Type=simple`{{}} and an `ExecStart=`{{}} that runs something long lived.
3. Restart it **only when it fails**, not when it exits cleanly.
4. Run it as user **`deploy`{{}}**, with working directory **`/srv/app`{{}}**.
5. An `[Install]`{{}} section, and the unit **enabled**.

<details><summary>Tip</summary>

```
man 5 systemd.service
man 7 systemd.directives
```{{exec}}

Two of those five directives are not in `systemd.service(5)`{{}} at all. Use
the index to find out which page owns them before you guess.

`Restart=`{{}} takes a named value, and there are several. Read the list rather
than assuming; "only when it fails" is one specific one.

</details>

<details><summary>Solution</summary>

```
cat > /etc/systemd/system/hello.service <<'EOF'
[Unit]
Description=hello

[Service]
Type=simple
ExecStart=/usr/bin/sleep 3600
Restart=on-failure
User=deploy
WorkingDirectory=/srv/app

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hello.service
```{{copy}}

</details>
