# Done

Your rounds are in `/tmp/lfcs-drill/history.json` — they disappear with the
session, so note the topic breakdown if you want to compare next week.

### What this measured, and what it did not

It measured whether you can produce a lookup command from memory. It did not
measure whether you can find an answer under time pressure with a task list
running down — that is what the other scenario, **LFCS: find it in the man
pages**, is for. Do that one if you have not.

### The five that pay for themselves

- `man -k word` — forgot the command name. Nothing appropriate? Run `mandb`.
- `man -K word` — forgot which page owns a directive. Narrow it: `-K -s 5`.
- `&word` — inside the pager, collapse a long page to the matching lines.
- `/EXAMPLES` — first move on any unfamiliar section 8 page.
- `man 7 systemd.directives` — the index of every systemd directive and the page
  that defines it.

### Worth carrying into the exam

Section 5 for anything you edit, section 8 for anything you run. When a name
exists in both, `whatis` tells you before you open the wrong one.
