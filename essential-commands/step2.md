# Create, configure and troubleshoot services

A systemd unit is a file, and the directives inside it are documented across
several pages rather than one. `systemd.service(5)` owns the service-specific
directives: `Type=`, `ExecStart=`, `Restart=`. The execution environment,
`User=`, `WorkingDirectory=`, `Environment=`, was factored out into
`systemd.exec(5)`, because sockets and mounts need it too. Guessing wrong here
costs a minute per lookup.

systemd caches unit files in memory. Editing one on disk changes nothing until
you tell systemd to reread them, and forgetting that is the classic reason a
fix appears not to work.

For troubleshooting there are two moves. One shows a unit's current state with
its last few log lines attached, which is usually enough. When it is not, the
journal has the rest, and you narrow it to a single unit rather than reading
everything the machine has ever logged.

### Task

**5.** The `systemctl` subcommand that makes systemd reread unit files after you
have edited one.

**6.** The `journalctl` flag that limits output to a single unit. Give the short
form, dash included. Case matters.

**7.** The page that documents `Restart=`. Page name, no section number.

**8.** The `systemctl` subcommand that shows a unit's state together with its
recent log lines.

```
answer 5 <subcommand>
answer 6 <flag>
answer 7 <page name>
answer 8 <subcommand>
```{{copy}}

<details><summary>Tip</summary>

```
man systemctl
man journalctl
```{{exec}}

`systemctl(1)` is long. Search for the heading rather than scrolling:
`/COMMANDS` then `n` to step through matches. For question 6, `&unit` inside
`journalctl(1)` collapses the page to the lines that mention units.

For question 7, if you are unsure which systemd page owns a directive, the
index answers it without guessing:

```
man 7 systemd.directives
```{{exec}}

</details>
