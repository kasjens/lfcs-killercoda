# Storage

The Storage domain is 20% of the LFCS exam and seven competencies: LVM, the
virtual filesystem, creating and troubleshooting filesystems, remote mounts,
swap, automounters, and I/O performance.

Every step here is real work. Two spare 512M disks are attached to this box for
the steps that need something to partition, so LVM and `mkfs` are done for
real rather than described.

One competency cannot be fully rehearsed here: remote filesystems need a server
to mount from, and there is not one. That step checks the `fstab` entry is
correct rather than that it mounts, and it says so.

> Do **LFCS prep 1: find it in the man pages** first if you have not. This
> scenario tells you what to achieve, not which page to open.

You are root. There is nothing on this box you can break that matters, and the
spare disks are files, so a mistake costs nothing.
