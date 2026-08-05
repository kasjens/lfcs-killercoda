# Configure filesystem automounters

An automounter mounts a filesystem the moment something touches the path, and
unmounts it again after a period of disuse. That solves the problem `fstab`{{}}
cannot: a file server that is not always reachable, or twenty exports of which
any one might be wanted.

The configuration is two files, and the relationship between them is the whole
of it.

**The master map** says which directory is managed and which map file describes
its contents. A line is: the mount point, the map file, then options such as
`--timeout=`{{}}. The master map is `/etc/auto.master`{{}}, and like most
things it reads a drop-in directory beside it, `/etc/auto.master.d/`{{}}, where
files conventionally end in `.autofs`{{}}.

**The map file** lists the keys under that directory. A key is the
**subdirectory name**, not a full path. So a master entry for `/data`{{}} plus
a map key `backup`{{}} produces `/data/backup`{{}}. Each key line is: the key,
mount options prefixed with `-`{{}}, then the location.

The consequence that surprises everyone: **the managed directory should not
contain anything you created**, and listing it may show nothing at all. autofs
owns that path. `ls /data`{{}} can come back empty while `ls /data/backup`{{}}
works perfectly, because the mount is triggered by the access, and a bare
listing of the parent does not access any key.

### Task

Configure the automounter so that `/data/backup`{{}} mounts on demand:

1. A master map entry for **`/data`{{}}** naming your map file, with a timeout.
2. A map file with a **`backup`{{}}** key pointing at
   **`fileserver:/export/backup`{{}}**, read-only.

Configuration only. There is no server to mount from, so the check reads the
two files.

<details><summary>Tip</summary>

```
man 5 auto.master
man 5 autofs
```{{exec}}

`auto.master(5)`{{}} shows the master line format, `autofs(5)`{{}} shows the
map entry format. They are two different pages and each covers one of the two
files.

</details>

<details><summary>Solution</summary>

```
mkdir -p /etc/auto.master.d
echo '/data /etc/auto.data --timeout=60' > /etc/auto.master.d/data.autofs
echo 'backup -fstype=nfs,ro fileserver:/export/backup' > /etc/auto.data
```{{copy}}

</details>
