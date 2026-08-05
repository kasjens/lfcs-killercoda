# Use remote filesystems and network block devices

There is no NFS server on this box, so this step checks that your `fstab`{{}}
entry is correct rather than that it mounts. That is a real limitation and
worth being honest about: you are practising the syntax and the options, not
the round trip.

A remote mount differs from a local one in three places.

**The source is `host:/export`{{}},** not a device. That colon is what tells
`mount`{{}} to hand off to the NFS helper rather than look for a block device.

**Boot ordering becomes your problem.** The network is not up when local
filesystems mount. An NFS entry without `_netdev`{{}} can be tried too early,
and depending on the init system either fails or hangs the boot waiting for a
server it cannot reach yet. `_netdev`{{}} says "this needs the network", and
systemd turns that into a dependency automatically.

**Failure is normal.** A local disk is either there or the machine is broken. A
file server can be rebooted while your box is up. `noauto`{{}} keeps a
temporarily unreachable server from blocking boot at all, at the cost of
mounting on demand or by hand. The pairing of `_netdev`{{}} with `noauto`{{}}
is the conservative default and the one to reach for under exam conditions.

NFS-specific options, `soft`{{}} against `hard`{{}}, `bg`{{}}, timeouts, are in
`nfs(5)`{{}}, not in `mount(8)`{{}} and not in `fstab(5)`{{}}. That is the
third page in the chain and the one people forget exists.

### Task

Write an `/etc/fstab`{{}} entry, without mounting it:

1. Source **`fileserver:/export/shared`{{}}**.
2. Mount point **`/mnt/shared`{{}}**, which must exist.
3. Type **nfs**.
4. Options including **`_netdev`{{}}** and **`noauto`{{}}**.

<details><summary>Tip</summary>

```
man 5 nfs
man 5 fstab
```{{exec}}

`nfs(5)`{{}} opens with the exact `fstab`{{}} line format for an NFS mount,
including where the options go. Read the first screen of it rather than
guessing from a local example.

</details>

<details><summary>Solution</summary>

```
mkdir -p /mnt/shared
echo 'fileserver:/export/shared /mnt/shared nfs _netdev,noauto,rw 0 0' >> /etc/fstab
```{{copy}}

</details>
