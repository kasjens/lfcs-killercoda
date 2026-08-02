# Create and manage local user and group accounts

An account is not one record. It is a row in `/etc/passwd`, a row in
`/etc/shadow`, and usually a row in `/etc/group`. The first holds identity, the
second holds the encrypted password and the ageing fields, and splitting them
is a security decision: `/etc/passwd` is world readable and `/etc/shadow` is
not.

The tools that write those files are administrative, so they are section 8.
That is the rule for this whole area, with one exception worth knowing.

`chage` changes password ageing, which sounds administrative, but its page is
in **section 1**. The reason is that an unprivileged user can run `chage -l` on
themselves to see when their own password expires. A command that ordinary
users can usefully run is a user command, whatever it manages. Section numbers
describe who the command is for, not how important it is.

The same logic explains `passwd`: `passwd(1)` is the command you run,
`passwd(5)` is the file format. Same name, two sections, and `whatis` shows
both.

### Task

**1.** The command that creates a local account.

**2.** The command that modifies an existing account.

**3.** The section the `chage` page lives in.

**4.** The page documenting the encrypted password and the ageing fields. Page
name, no section number.

```
answer 1 <command>
answer 2 <command>
answer 3 <number>
answer 4 <page name>
```{{copy}}

<details><summary>Tip</summary>

```
man -k account
whatis chage passwd shadow
```{{exec}}

Question 1 has a tempting near-miss on Debian and Ubuntu: there is a friendlier
wrapper script with a similar name. The exam is distribution agnostic, so the
answer is the portable tool, which is the one with the section 8 page.

</details>
