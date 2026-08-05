# Done

Four tasks performed on a real box, plus the LDAP lookups, covering the five
competencies that make up Users and Groups, 10% of the exam.

The moves worth keeping:

- **Section numbers describe the audience, not the importance.** `chage`{{}} is
  section 1 because you can run `chage -l`{{}} on yourself. `useradd`{{}} is 8
  because you cannot usefully run it on yourself at all.
- **Same name, two sections** is normal here. `passwd(1)`{{}} is the command,
  `passwd(5)`{{}} is the file. `whatis`{{}} shows both in one line.
- **PAM modules are 8, their config files are 5**, and the config page is
  usually the module name plus a suffix. Once you have the module you have the
  file.
- **`man -k`{{}} on the concept**, not the tool: "name service", "access
  control list", "password ageing".

Three traps that were in here on purpose:

1. `man profile`{{}} is not `/etc/profile`{{}}. Shell startup files are
   documented under INVOCATION in `bash(1)`{{}}.
2. A hard limit on its own enforces nothing. It is the ceiling for the soft
   limit, and the soft limit is what is actually applied.
3. An ACL mask silently reduces entries that look like they grant more, and
   `chmod`{{}} on the group bits rewrites it.

One thread worth pulling across domains: PAM limits do not apply to systemd
services, because a service never logged in. That is the same fact from the
other side in the Essential Commands domain, where the answer is
`systemd.resource-control(5)`{{}}.

Next: storage at 20%, or networking and operations at 25% each.
