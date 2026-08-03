# Done

Fifty-six lookups across the five topics that make up the retrieval skill: the
sections table, searching by description, the pager, documentation outside the
man pages, and the LFCS-specific pages.

The moves worth keeping:

- **Section first, name second.** `man 5 fstab` beats `man fstab` because the
  number is what saves you when a name lives in two sections.
- **`man -k` searches descriptions and takes a regex**, so `man -k '^chage'`
  anchors it. `man -K` searches page bodies and is slow, so narrow it with
  `-s`.
- **`&pattern` in the pager** collapses a nine-screen page to the lines that
  matter. It is the single biggest time saver in this whole drill.
- **`whatis` before `man`** when all you need is a section number.

Three that catch nearly everyone:

1. `chage` is section **1**, not 8.
2. `WorkingDirectory=` is in `systemd.exec(5)`, not `systemd.service(5)`.
3. The `OnCalendar=` grammar is in `systemd.time(7)`, not `systemd.timer(5)`.

For spaced repetition rather than a single pass, the scored version is still
installed and tracks what you missed:

```
drill -n 20
drill --review
```{{copy}}

Next: the five domain scenarios, where you stop naming commands and start
fixing a box.
