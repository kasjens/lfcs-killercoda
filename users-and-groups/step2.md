# Manage personal and system-wide environment profiles

Environment reaches a login by two independent paths, and they run at different
times.

The shell path is the familiar one: `/etc/profile` system-wide, then
`~/.bash_profile` or `~/.bashrc` per user. None of these has a man page of its
own. They are documented inside the shell's page, under INVOCATION, because
which file gets read depends on whether the shell is a login shell or an
interactive one.

There is a trap here of the same shape as `man ulimit`. Asking `man` for
`profile` does not give you `/etc/profile`. On a box with BPF tooling installed
it hands you a CPU profiler with that name.

Editing `/etc/profile` directly is the wrong instinct. It is package owned, so
an upgrade can overwrite it. It sources every `.sh` file in a drop-in directory
instead, and that is where system-wide additions belong.

The default umask for new logins is a different mechanism again. It is not a
shell setting, it is a login setting, and it lives with the other account
defaults like `PASS_MAX_DAYS`.

### Task

1. Make **`EDITOR=vim`** appear in every **login** shell, set system-wide, not
   in any one user's dotfiles and not by editing `/etc/profile` itself.
2. Set the system-wide default **`UMASK`** for new logins to **`027`**.

The check starts a login shell with an empty environment and reads `EDITOR` out
of it, so exporting it in your current session will not pass.

<details><summary>Tip</summary>

```
man 1 bash
man 5 login.defs
```{{exec}}

In `bash(1)`, search for `INVOCATION` to see exactly which files a login shell
reads and in what order. That tells you which directory the drop-in belongs in.

Check your work the same way the verifier does:

```
env -i bash -lc 'echo $EDITOR'
```{{exec}}

</details>

<details><summary>Solution</summary>

```
echo 'export EDITOR=vim' > /etc/profile.d/lfcs.sh
chmod 644 /etc/profile.d/lfcs.sh
sed -i -E 's/^[[:space:]]*UMASK[[:space:]]+.*/UMASK\t\t027/' /etc/login.defs
```{{copy}}

</details>
