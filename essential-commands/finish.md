# Done

Six tasks performed on a real box, covering the six competencies that make up
Essential Commands, 20% of the exam.

The moves worth keeping:

- **Per-subcommand pages are hyphenated.** `git-clone(1)`, `openssl-req(1ssl)`.
  Two toolkits, one convention, and it turns "I do not know the flags" into a
  page you can read on the spot.
- **`systemd.directives(7)`** settles which page owns a directive, instead of
  opening two and guessing.
- **Drop-ins over edits.** `<unit>.d/*.conf` survives package upgrades and
  `systemctl cat` shows you the merged result.
- **`du | sort -h | tail`** finds an offender in one line. Plain `du -h` on a
  real tree is unreadable.

Five traps that were in here on purpose:

1. `User=` and `WorkingDirectory=` are in `systemd.exec(5)`, not
   `systemd.service(5)`.
2. Enabling a unit is a symlink, and it needs an `[Install]` section to point
   at. No `[Install]`, no enable.
3. `sar` ships with its collector **disabled** on Debian and Ubuntu, so it can
   be installed and still have nothing to report.
4. PAM limits never reach a systemd service, because a service never logged in.
   That is `systemd.resource-control(5)` territory.
5. `du` cannot see a deleted file that is still held open, which is why it and
   `df` can disagree and both be right.

Next: users and groups is the smallest domain at 10%. Storage is 20%.
Networking and operations are 25% each.
