# Which page defines this?

systemd spreads across roughly fifteen pages, and the directive you want is
rarely on the page you would guess. `systemd.service(5)` documents `Type=`,
`ExecStart=` and `Restart=` — but not `User=`, not `Environment=`, and not
`WorkingDirectory=`. Those were factored out, because sockets and mounts need
them too.

Two ways to find the page that owns a word:

```
man -K WorkingDirectory
```{{exec}}

`-K` is a brute-force search through the body of every page. Capital K, and the
difference from lowercase `-k` is not cosmetic: `-k` only searches the one-line
descriptions.

The faster route for systemd specifically is the directive index, which lists
every directive and the page that defines it:

```
man 7 systemd.directives
```{{exec}}

### Task

**10.** Which man page defines **`WorkingDirectory=`**? Page name, no section
number.

**11.** Which page is the index itself, the one listing every directive against
the page that defines it? Page name again.

**12.** Which section is that index page in?

```
answer 10 <page name>
answer 11 <page name>
answer 12 <number>
```{{copy}}

<details><summary>Tip</summary>

Inside `systemd.directives(7)`, search for the directive: `/WorkingDirectory`

Question 12 is worth pausing on. An index of directives is not a file you edit
and not a command you run, so neither 5 nor 8 fits. `man -k systemd.directives`
gives you the number without opening anything.

</details>

<details><summary>Solution</summary>

```
answer 10 systemd.exec
answer 11 systemd.directives
answer 12 7
```{{copy}}

`WorkingDirectory=` was factored out of `systemd.service(5)` because sockets
and mounts need it too. The directive index is section 7 because it describes
neither a file nor a command.

</details>
