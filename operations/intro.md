# Operations and deployment

The other 25% domain, and the broadest: kernel parameters, service
troubleshooting, scheduled jobs, packages and pinning, boot recovery, virtual
machines, container engines, and mandatory access control.

Six of the eight steps are real work on this box, and two of them are
diagnosis rather than construction. A unit file and an `/etc/fstab` entry are
deliberately broken. Finding out *why* is the exercise; the fix is small once
you have.

Two competencies cannot be rehearsed here and say so rather than pretending.
**libvirt** needs nested virtualisation this backend does not offer.
**SELinux** is not what Ubuntu enforces: this box runs AppArmor, and a policy
you write but never enforce teaches the wrong lesson. Both are lookup steps,
grounded in pages that really are installed.

> Do **LFCS prep 1: find it in the man pages** first if you have not.

You are root.
