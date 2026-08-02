# Done

Twenty-four lookups across the six competencies that make up Essential
Commands, 20% of the exam.

The moves worth keeping:

- **Per-subcommand pages are hyphenated.** `git-clone(1)`, `openssl-x509(1ssl)`.
  Two toolkits, one convention, and it turns "I do not know the flags" into a
  page you can read on the spot.
- **`man -k` on the description, not the name.** These tools describe
  themselves: "report virtual memory statistics", "list open files". Search the
  sentence you would use, not the command you cannot remember.
- **`whatis` before `man`** when all you need is the section number.
- **Section 8 means administrative.** Rebuilding a trust store, listing open
  files and sampling virtual memory are all system jobs, which is why none of
  the three are in section 1.

Four traps that were in here on purpose:

1. `vmstat` is section **8**, not 1.
2. `man ulimit` gives you the C function in section **3**. The shell builtin
   lives in `bash(1)`.
3. PAM limits do not apply to systemd services. Those need
   `systemd.resource-control(5)`.
4. A directory walk cannot see a deleted file that is still held open, which is
   why the two disk-space commands can disagree and both be right.

Next: pick another domain. Users and groups is the smallest at 10%, networking
and operations are the heaviest at 25% each.
