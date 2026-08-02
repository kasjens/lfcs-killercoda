# Create and manage local user and group accounts

An account is not one record. It is a row in `/etc/passwd`, a row in
`/etc/shadow`, and usually a row in `/etc/group`. The first holds identity, the
second holds the encrypted password and the ageing fields, and splitting them
is a security decision: `/etc/passwd` is world readable and `/etc/shadow` is
not.

The tools that write those files are administrative, so they are section 8.
That is the rule for this whole area, with one exception worth knowing.

`chage` changes password ageing, which sounds administrative, but its page is
in **section 1**. An unprivileged user can run `chage -l` on themselves to see
when their own password expires. A command ordinary users can usefully run is a
user command, whatever it manages.

That split matters for this task. Account expiry is not a `useradd` field you
can see in `/etc/passwd`. It lives in `/etc/shadow`, and it is set with a
different tool from the one that creates the account.

### Task

Build it on the box. Nothing to type into an answer file here, the check reads
the system.

1. A group **`webops`** with GID **4000**.
2. A user **`deploy`** with home **`/home/deploy`**, login shell **`/bin/bash`**,
   and `webops` as its **primary** group. The home directory must exist.
3. `deploy`'s account must **expire on 31 December 2026**.

Any route that produces that result passes. Press **Check** when you are done.

<details><summary>Tip</summary>

```
man 8 useradd
man 8 groupadd
man 1 chage
```{{exec}}

`useradd` does not create the home directory unless you ask it to, and the flag
for the primary group is not the same as the one for supplementary groups. Read
the difference before you pick.

For the expiry, `chage -l deploy` shows you what is currently set, which is the
quickest way to confirm you got the date format right.

</details>

<details><summary>Solution</summary>

```
groupadd -g 4000 webops
useradd -m -d /home/deploy -s /bin/bash -g webops deploy
chage -E 2026-12-31 deploy
```{{copy}}

</details>
