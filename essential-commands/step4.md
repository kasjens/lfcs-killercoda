# Determine application and service specific constraints

Resource limits reach a process by two completely separate routes, and knowing
which one applies is most of the work.

The old route is PAM. When a user logs in, `pam_limits` reads a config file and
applies limits to that session. Those limits are inherited by everything the
session starts. This is the route that governs a person at a shell.

The new route is systemd. A service started by systemd never went through a
login, so PAM limits do not apply to it. Its constraints come from directives
in the unit, and they are documented on their own page covering `CPUQuota=`,
`MemoryMax=` and the rest. If you set a limit in the PAM file and the service
ignores it, this is why.

There is a trap in the middle. The shell command everyone uses to inspect
limits is a **shell builtin**, so it has no page of its own. Asking `man` for
it hands you a C library function of the same name in section 3, which is a
different thing entirely. The builtin is documented inside the shell's own
page.

### Task

**13.** The file that sets per-user resource limits at login. Filename alone is
fine.

**14.** The section `man ulimit` actually lands you in.

**15.** The page that documents the shell builtin `ulimit`.

**16.** The page documenting `CPUQuota=` and `MemoryMax=`. Page name, no section
number.

```
answer 13 <file>
answer 14 <number>
answer 15 <page name>
answer 16 <page name>
```{{copy}}

<details><summary>Tip</summary>

```
whatis ulimit
man 7 systemd.directives
```{{exec}}

For question 15, once you are in the right page it is enormous, so do not
scroll. Search for the builtin by name, or use `&ulimit` to collapse the page
to the lines that mention it.

</details>
