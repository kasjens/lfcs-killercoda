# Configure the OpenSSH server and client

Four pages, and picking the wrong one wastes real time:

| Page | What it is |
|---|---|
| `sshd(8)`{{}} | the server daemon |
| `sshd_config(5)`{{}} | **the server's configuration** |
| `ssh(1)`{{}} | the client command |
| `ssh_config(5)`{{}} | the client's configuration |

The two that get confused are `sshd_config`{{}} and `ssh_config`{{}}. One
letter, and editing the wrong one produces a change that silently does nothing.

Four behaviours of `sshd_config`{{}} that are not obvious.

**First occurrence wins.** Unlike most config files, sshd takes the *first*
setting of a keyword and ignores later ones. Appending your line to the bottom
of a file that already sets it changes nothing. On modern Debian and Ubuntu
there is also an `Include /etc/ssh/sshd_config.d/*.conf`{{}} at the **top**,
which means drop-ins win over everything below them.

**`PermitRootLogin`{{}} has more than two values.** The default on many systems
is `prohibit-password`{{}}, which still allows key-based root login. If a task
says disable root login, `no`{{}} is the answer and `prohibit-password`{{}} is
not.

**A keyword that is not in the file cannot be edited into it.** Most of these
ship commented out, some images ship without them at all, and a substitution
that matches no line changes nothing and says nothing about it. Read the file
back after editing, or add the line rather than rewriting one.

**`sshd -t`{{}} validates the file.** A syntax error means the daemon will not
restart, and finding that out during a reload on a remote box is how people
lock themselves out. Validate first, always.

Changing the port has a consequence beyond sshd: anything filtering traffic
needs to know, and on SELinux systems the port needs labelling too.

### Task

Harden the server configuration. Do not restart anything.

1. Listen on port **2222**.
2. **Disallow root login entirely**, not just by password.
3. **Disable password authentication**, leaving keys only.

The check reads the effective settings and, if `sshd`{{}} is installed, asks it
to validate the file.

<details><summary>Tip</summary>

```
man 5 sshd_config
```{{exec}}

Read what `PermitRootLogin`{{}} actually accepts before choosing a value. There
are four, and two of them permit a root login.

See what is set already, drop-ins included, before you decide how to change it:

```
grep -rniE '^[[:space:]]*(Port|PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/
```{{exec}}

Nothing printed for a keyword means there is no line to edit and you have to
add one.

Validate with `sshd -t`{{}}. Silence means it parses.

</details>

<details><summary>Solution</summary>

```
for f in /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf; do
  [ -f "$f" ] && sed -i -E '/^[[:space:]]*#?[[:space:]]*(Port|PermitRootLogin|PasswordAuthentication)[[:space:]]/d' "$f"
done
printf 'Port 2222\nPermitRootLogin no\nPasswordAuthentication no\n' >> /etc/ssh/sshd_config
sshd -t
```{{copy}}

</details>
