# Diagnose and troubleshoot a service

`/etc/systemd/system/broken.service` is wrong in two ways, and both are worth
recognising on sight.

**A mistyped section header is silent.** systemd does not reject an unknown
section: it ignores it and everything under it. A unit with `[Servce]` parses
cleanly, starts nothing, and reports no syntax error anywhere obvious.
`systemd-analyze verify <unit>` is the command that does complain, and it is
the fastest way to find this whole class of fault.

**An ExecStart that does not exist fails at start, not at load.** The unit is
valid, `daemon-reload` is happy, and the failure only appears when you try to
run it, as status **203/EXEC**. That code means specifically that the binary
could not be executed, which is a different problem from the service starting
and then exiting, and the number is worth memorising.

The diagnostic order worth internalising:

1. `systemctl status <unit>` for the last log lines and the exit code.
2. `journalctl -u <unit>` for the rest.
3. `systemd-analyze verify <unit>` for problems in the file itself.
4. `systemctl cat <unit>` to see the unit plus every drop-in as merged.

`ExecStart` must be an absolute path. systemd does not use `$PATH`, which
catches people who tested the command in a shell first and found it worked.

### Task

Repair `/etc/systemd/system/broken.service` so that:

1. It has a real **`[Service]`** section.
2. `ExecStart` is an **absolute path to something that exists** on this box.

<details><summary>Tip</summary>

```
systemd-analyze verify /etc/systemd/system/broken.service
man 5 systemd.service
```{{exec}}

The verify output names the section it did not recognise. For the second
fault, `command -v` or `ls` tells you whether the path is real.

</details>

<details><summary>Solution</summary>

```
printf '[Unit]\nDescription=broken\n\n[Service]\nExecStart=/usr/bin/true\n' > /etc/systemd/system/broken.service
systemctl daemon-reload
```{{copy}}

</details>
