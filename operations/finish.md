# Done

Six tasks performed and two competencies looked up, covering the eight that
make up Operations and Deployment, 25% of the exam.

The moves worth keeping:

- **Live and persistent are two jobs.** `sysctl -w`{{}} now, a drop-in for next
  boot, `sysctl -p`{{}} to avoid the reboot. The same shape as mounting against
  `fstab`{{}}, and the same half-mark if you do one.
- **`systemd-analyze verify`{{}}** finds faults in a unit file that
  `daemon-reload`{{}} accepts without complaint.
- **`mount -a`{{}} and `findmnt --verify`{{}} before rebooting**, every time
  you touch `fstab`{{}}. Rebooting to find out is how an edit becomes a
  rescue-media afternoon.
- **`apt-cache policy <pkg>`{{}}** explains why apt chose what it chose, which
  no amount of reading the sources file will.

Six traps that were in here on purpose:

1. A mistyped section header in a unit is **silent**. systemd ignores the
   section and everything under it.
2. `203/EXEC`{{}} means the binary could not be executed, which is a different
   failure from the service starting and exiting.
3. `/etc/cron.d`{{}} files take a **sixth field, the user**. A personal crontab
   line pasted there turns the username into the command.
4. The `OnCalendar=`{{}} grammar is in `systemd.time(7)`{{}}, not
   `systemd.timer(5)`{{}}.
5. A pin priority **above 1000 will downgrade** a package. That is the whole
   point of the number, and the reason 1001 rather than 999.
6. `nofail`{{}} and an fsck pass of `0`{{}} are both needed for an optional
   filesystem. One without the other still breaks the boot.

Two competencies were lookups, and honestly so. libvirt needs nested
virtualisation this backend does not have. SELinux is not what Ubuntu enforces,
so the step covers AppArmor, which is, and maps the vocabulary across:
permissive is complain, `getenforce`{{}} is `aa-status`{{}}.

That is all five domains. The two prep scenarios are still the fastest way to
get quicker at the lookups themselves, and worth a second pass closer to the
exam.
