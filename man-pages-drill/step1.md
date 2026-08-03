# Warm up

Start with one topic so the format is familiar before the score counts.

```
drill -t sections -n 8
```{{exec}}

Sections are worth doing first: they are the largest topic, and almost every
other lookup starts with picking the right number.

Three that catch most people:

- `chage` is section **1**, not 8 — an unprivileged user can run `chage -l` on
  their own account.
- `bind` mounts are documented in `mount(8)`, not in the fstab page. All
  `fstab(5)` gives you is the six columns, and it hands column four to
  `mount(8)`.
- `User=` and `WorkingDirectory=` are in `systemd.exec(5)`, not
  `systemd.service(5)`.

When an item surprises you, check it in the terminal before moving on:

```
whatis chage
man -w 5 fstab
```{{exec}}

Press **Check** when a round has finished.

<details><summary>Other topics</summary>

```
drill --list
drill -t discovery -n 10
drill -t pager -n 8
drill -t beyond -n 8
drill -t exam -n 8
```{{copy}}

</details>
