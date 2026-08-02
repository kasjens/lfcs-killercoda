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

Which man page defines **`WorkingDirectory=`**? Record the page name without the
section number.

```
answer 4 <page name>
```{{copy}}

<details><summary>Tip</summary>

Inside `systemd.directives(7)`, search for the directive: `/WorkingDirectory`

</details>
