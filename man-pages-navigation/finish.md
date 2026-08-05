# Done

Fifteen lookups, and none of them needed you to know the answer in advance.

The moves worth keeping:

- **`man -k word`{{}}** when you have forgotten the command name. If it says
  nothing appropriate, run `mandb`{{}}.
- **`man -K word`{{}}** when you have forgotten which page owns a directive.
  Slow, so narrow it: `man -K -s 5 word`{{}}.
- **`&word`{{}}** inside the pager, to collapse a nine-screen page to the six
  lines that matter.
- **`/EXAMPLES`{{}}** first, on any unfamiliar admin command. Most section 8
  pages have working examples you can adapt faster than you can read the flag
  list.
- **section 5 for anything you edit**, section 8 for anything you run.

Two traps that were in here on purpose: `WorkingDirectory=`{{}} is in
`systemd.exec(5)`{{}} rather than `systemd.service(5)`{{}}, and the
`OnCalendar=`{{}} grammar is in `systemd.time(7)`{{}} rather than
`systemd.timer(5)`{{}}.

Next: **LFCS prep 2: man page speed drill**, fifty-six typed answers in this
same terminal.
