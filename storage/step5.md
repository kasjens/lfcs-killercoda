# Configure and manage swap space

Swap can be a partition or a plain file, and the file is what you reach for
when the machine is already built and you cannot repartition it.

Four steps, and skipping any one of them fails in a different way.

**Allocate the space.** `dd` or `fallocate`. On some filesystems `fallocate`
produces a file with holes that the kernel refuses to swap to, which is why
`dd` still appears in every guide.

**Restrict the permissions.** A swap file holds whatever the kernel paged out
of memory, which can include anything any process had in RAM. World readable is
a genuine disclosure, and `swapon` warns about it.

**Write the signature.** `mkswap` marks the file as swap. Without it `swapon`
refuses, however large the file is. After it, `blkid` reports the file as type
`swap`, which is how you confirm the step took.

**Activate and persist.** `swapon` uses it now; an `/etc/fstab` line brings it
back at boot. Those are separate, same as with any other mount.

The `fstab` line for swap has a quirk worth knowing: **column two is
meaningless**, because swap has no mount point. The convention is to write
`none`, and `swap` also appears in the wild. Column three is `swap`, and column
four is usually `sw` or `defaults`.

Priority is set with `pri=`, and equal priorities stripe across devices rather
than filling one first.

### Task

Add a swap file. It goes at **`/srv/swapfile`** for this exercise, since the
root filesystem here is small:

1. **256M**.
2. Permissions **600**.
3. A valid swap signature.
4. An `/etc/fstab` entry so it comes back at boot.

You do not need to activate it: this box shares its kernel, so `swapon` would
reach beyond the scenario.

<details><summary>Tip</summary>

```
man 8 mkswap
man 8 swapon
man 5 fstab
```{{exec}}

Confirm the signature with `blkid /srv/swapfile`, which should report
`TYPE="swap"`.

</details>

<details><summary>Solution</summary>

```
dd if=/dev/zero of=/srv/swapfile bs=1M count=256
chmod 600 /srv/swapfile
mkswap /srv/swapfile
echo '/srv/swapfile none swap sw 0 0' >> /etc/fstab
```{{copy}}

</details>
