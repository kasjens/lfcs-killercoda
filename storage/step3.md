# Create, manage and troubleshoot filesystems

A filesystem needs three things written down before it is useful: what it is,
what it is called, and how to find it again.

**What it is** comes from `mkfs`, which is a front end. `mkfs.ext4` and
`mkfs.xfs` are separate programs with separate pages and genuinely different
options, so `man mkfs` is rarely the page you want. Note that on Debian and
Ubuntu `man mkfs.ext4` lands you in `mke2fs(8)`, because one program builds all
the ext filesystems.

**What it is called** is the label, and it is optional but cheap. `blkid`
prints the label, UUID and type of every block device, and it is the single
most useful command in this competency.

**How to find it again** is the part that matters most. Device names are not
stable. `/dev/sdb` can become `/dev/sdc` when a disk is added, and a `fstab`
entry naming a device directly will then mount the wrong filesystem, or fail to
boot. Every filesystem gets a UUID when it is created, and that follows the
filesystem rather than the slot it is plugged into. Referring to it by UUID in
`fstab` is not a style preference, it is the reason the box still boots next
month.

Column six of `fstab` controls `fsck` order: `0` to skip, `1` for the root
filesystem, `2` for everything else.

### Task

Use the **second** spare disk, the one you did not give to LVM:

1. An **ext4** filesystem on it, with the label **`DATA`**.
2. Mounted at **`/srv/disk`**.
3. An `/etc/fstab` entry that refers to it **by UUID**, so it survives the
   device being renamed.

<details><summary>Tip</summary>

```
lsblk
blkid
man 8 mke2fs
man 5 fstab
```{{exec}}

`mke2fs(8)` has the flag for setting a label at creation time. If you forget
it, `e2label` sets one afterwards.

`blkid -o value -s UUID <device>` prints just the UUID, which saves retyping a
36-character string.

</details>

<details><summary>Solution</summary>

```
dev=$(tail -n1 /tmp/lfcs-spares)
mkfs.ext4 -L DATA "$dev"
mkdir -p /srv/disk
mount "$dev" /srv/disk
echo "UUID=$(blkid -o value -s UUID "$dev") /srv/disk ext4 defaults 0 2" >> /etc/fstab
```{{copy}}

</details>
