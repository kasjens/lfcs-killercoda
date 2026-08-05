# Configure and manage LVM storage

LVM inserts a layer between disks and filesystems so that the filesystem stops
caring which disk it is on, or how many.

Three nouns, in order. A **physical volume** is a disk or partition initialised
for LVM. A **volume group** is a pool of one or more physical volumes. A
**logical volume** is a slice carved out of that pool, and it is the thing you
put a filesystem on. The commands are named after the nouns with a two-letter
prefix: `pv*`{{}}, `vg*`{{}}, `lv*`{{}}. Once you know that, `pvcreate`{{}},
`vgextend`{{}} and `lvremove`{{}} need no memorising, and `man -k '^lv'`{{}}
lists the whole family.

All of them are section 8.

Two things that catch people out. Sizes take a suffix, and `-L 200M`{{}} means
an absolute size while `-l`{{}} takes extents or a percentage, which is a
different flag entirely. And a logical volume is not usable until it has a
filesystem on it, so `lvcreate`{{}} succeeding tells you nothing about whether
you can store anything yet.

Growing is where LVM earns its place: extend the logical volume, then grow the
filesystem to fill it. Two steps, and forgetting the second is why "I extended
it and nothing changed" is such a common complaint.

### Task

Two spare disks are attached. Find them, then build:

1. A volume group called **`datavg`{{}}**.
2. A logical volume called **`datalv`{{}}**, at least **200M**.
3. An **ext4** filesystem on it.
4. Mounted at **`/srv/lv`{{}}**.

<details><summary>Tip</summary>

```
lsblk
man 8 pvcreate
man 8 vgcreate
man 8 lvcreate
```{{exec}}

`lsblk`{{}} shows the spare devices as `loop`{{}} entries with no mount point.
Use one of those, not the disk the system is running from.

</details>

<details><summary>Solution</summary>

```
dev=$(head -n1 /tmp/lfcs-spares)
pvcreate -y "$dev"
vgcreate datavg "$dev"
lvcreate -L 200M -n datalv datavg
mkfs.ext4 /dev/datavg/datalv
mkdir -p /srv/lv
mount /dev/datavg/datalv /srv/lv
```{{copy}}

</details>
