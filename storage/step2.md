# Manage and configure the virtual file system

Not everything mounted is on a disk. `proc`{{}}, `sysfs`{{}}, `devtmpfs`{{}}
and `tmpfs`{{}} are kernel-backed filesystems with no storage behind them, and
they are mounted exactly like real ones. `findmnt`{{}} shows the whole tree
with types, which is a better first move than `mount`{{}} with no arguments.

`tmpfs`{{}} is the one you configure deliberately. It lives in page cache, so
it is memory backed but can be swapped, and it grows on demand up to a limit.
That limit is the important part: **an unbounded tmpfs defaults to half of
RAM**, and a runaway writer can take all of it and put the machine under memory
pressure that looks like a leak somewhere else entirely.

Two ideas get confused here. Mounting something changes the running system and
is forgotten at reboot. Writing it in `/etc/fstab`{{}} makes it happen at boot
and changes nothing right now. A task that says "mount it and make it
permanent" is asking for both, and doing only one is the usual half-mark.

The `size=`{{}} option accepts a suffix or a percentage, and `mode=`{{}}
matters for a shared scratch directory, because a fresh tmpfs is owned by root
with default permissions.

### Task

Provide a memory-backed scratch area at **`/srv/cache`{{}}**:

1. A **tmpfs**, limited to **64M**.
2. Mounted **now**.
3. **And** written into `/etc/fstab`{{}} so it comes back after a reboot.

<details><summary>Tip</summary>

```
man 5 fstab
man 8 mount
findmnt
```{{exec}}

The tmpfs-specific options are not in `fstab(5)`{{}}. Column four hands off to
`mount(8)`{{}}, and the filesystem-specific options live there. That split is
worth internalising: `fstab(5)`{{}} describes the six columns, `mount(8)`{{}}
describes what can go in column four.

Confirm with `findmnt /srv/cache`{{}}, which shows the type and the options the
kernel actually applied.

</details>

<details><summary>Solution</summary>

```
mkdir -p /srv/cache
echo 'tmpfs /srv/cache tmpfs size=64M,mode=1777 0 0' >> /etc/fstab
mount -t tmpfs -o size=64M,mode=1777 tmpfs /srv/cache
```{{copy}}

</details>
