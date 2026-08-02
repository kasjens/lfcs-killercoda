# Done

Seven tasks on a real box, covering the seven competencies that make up
Storage, 20% of the exam.

The moves worth keeping:

- **`pv*`, `vg*`, `lv*`.** Three nouns, one prefix each, all section 8. Once
  you see the pattern, `man -k '^lv'` lists the whole family and you never need
  to memorise another LVM command.
- **`blkid` and `findmnt` before anything else.** One tells you what a device
  holds, the other tells you what the kernel currently has mounted and with
  which options. Between them they answer most storage questions without a
  guess.
- **`fstab(5)` describes six columns; `mount(8)` describes column four.** The
  filesystem-specific options are never on the `fstab` page, and NFS has a
  third page again in `nfs(5)`.
- **Mounting and persisting are two jobs.** A task that says "and make it
  permanent" wants both, and doing one is half a mark.

Five traps that were in here on purpose:

1. `man mkfs.ext4` lands you in `mke2fs(8)`, because one program builds every
   ext filesystem.
2. Device names are not stable. A `fstab` entry naming `/dev/sdb` mounts the
   wrong filesystem the day a disk is added, which is why UUIDs exist.
3. An unbounded `tmpfs` defaults to **half of RAM**, and looks like a memory
   leak somewhere else when something fills it.
4. Swap `fstab` column two is meaningless. Swap has no mount point, so it reads
   `none`.
5. Extending a logical volume does not grow the filesystem on it. That is a
   second command, and forgetting it is why "nothing changed".

Next: networking and operations are 25% each, the two heaviest domains.
