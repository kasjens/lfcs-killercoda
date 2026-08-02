# Manage personal and system-wide environment profiles

Environment reaches a login by two independent paths, and they run at different
times.

The shell path is the familiar one: `/etc/profile` system-wide, then
`~/.bash_profile` or `~/.bashrc` per user. None of these has a man page of its
own. They are documented inside the shell's page, under INVOCATION, because
which file gets read depends on whether the shell is a login shell or an
interactive one.

There is a trap here of exactly the same shape as `man ulimit`. Asking `man`
for `profile` does not give you `/etc/profile`. On a machine with BPF tooling
installed it hands you a CPU profiler with that name. The file you want is in
the shell page.

The PAM path runs earlier, before any shell starts, which is why it also
applies to logins that never get a shell at all. A PAM module reads a
configuration file and sets variables from it. Because it runs at the PAM
layer, it is the only one of the two that affects graphical sessions and some
service logins.

Defaults that apply to account creation and password ageing live in a third
file again, `login.defs`, which is where `UMASK` and `PASS_MAX_DAYS` are set
system-wide.

### Task

**5.** The page that documents `/etc/profile` and `~/.bashrc`.

**6.** The PAM module that sets environment variables at login.

**7.** The configuration page for that module.

**8.** The page defining `UMASK` and `PASS_MAX_DAYS`.

```
answer 5 <page name>
answer 6 <module>
answer 7 <page name>
answer 8 <page name>
```{{copy}}

<details><summary>Tip</summary>

```
man -k pam_ | head -20
man -k login
```{{exec}}

For question 5, do not trust `man profile`. Work out which page documents shell
startup files instead, then confirm with `man -K '\.bashrc'` if you want proof.

Questions 6 and 7 are the module and its config file. PAM modules are section
8, their config files are section 5, and the config page is usually the module
name with a suffix.

</details>
