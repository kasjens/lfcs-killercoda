# Create and enforce mandatory access control

The syllabus names SELinux. This box runs **AppArmor**, because that is what
Ubuntu enforces, and the SELinux tooling is not installed and would not be
enforcing anything if it were. Writing a policy that never takes effect teaches
the wrong lesson, so this step is lookups against the MAC system that is
actually here, plus the mapping between the two.

Both answer the same question: discretionary permissions let the owner of a
file decide who reads it, and a compromised process inherits whatever its user
can do. Mandatory access control adds a policy the process cannot override,
however privileged it is.

They differ in what the policy attaches to.

**SELinux labels everything.** Every file, port and process carries a context,
and rules are written between labels. That is powerful and total, and it is why
a mislabelled file breaks a service in a way no `ls -l` explains, and why
`restorecon` exists.

**AppArmor confines paths.** A profile names an executable and lists the paths
it may touch. Simpler to read, easier to write, and blind to a file reached by
a different path.

The vocabulary maps closely enough to be worth holding:

| SELinux | AppArmor |
|---|---|
| `getenforce` | `aa-status` |
| permissive mode | complain mode |
| enforcing mode | enforce mode |
| `setsebool` | edit the profile and reload |

**Permissive and complain both mean the same thing**: log what would have been
denied, deny nothing. That is the mode you use to find out what a policy needs
before turning it on, and the first thing to check when a service misbehaves
for no visible reason. On SELinux the denials are in the audit log; on AppArmor
they are in the kernel log, and `dmesg | grep -i apparmor` finds them.

### Task

Three lookups about the MAC system on this box.

**1.** The page describing the MAC system Ubuntu actually enforces.

**2.** The page describing the profile language, the one under `/etc/apparmor.d`.

**3.** The command reporting which profiles are loaded and in what mode.

```
answer 4 <page name>
answer 5 <page name>
answer 6 <command>
```{{copy}}

<details><summary>Tip</summary>

```
man -k apparmor
```{{exec}}

Three different section numbers between the three answers, which is itself the
clue: an overview, a file format, and an administrative command.

</details>

<details><summary>Solution</summary>

```
answer 4 apparmor
answer 5 apparmor.d
answer 6 aa-status
```{{copy}}

Three sections between three answers: `apparmor(7)` is the overview,
`apparmor.d(5)` is the profile file format, and `aa-status(8)` is the
administrative command. That spread is the same shape SELinux uses.

</details>
