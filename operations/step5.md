# Recover from a filesystem failure that blocks boot

The single most common way to make a Linux box unbootable is a bad line in
`/etc/fstab`{{}}. It is also the most common recovery task in an exam, because
it is quick to cause and unambiguous to fix.

Two columns decide whether a missing device is an inconvenience or a failed
boot.

**Column four, the options.** By default a filesystem in `fstab`{{}} is
required. If the device is not there, systemd waits for it, then drops to
emergency mode. `nofail`{{}} says the boot should carry on without it.
`nofail`{{}} plus `_netdev`{{}} is the standard pairing for anything remote.

**Column six, the fsck pass.** `0`{{}} skips the check, `1`{{}} is the root
filesystem, `2`{{}} is everything else. A non-zero pass on a device that does
not exist gives you a failed fsck on top of a failed mount, so an optional
filesystem wants `0`{{}} here.

The habit that prevents all of this: after editing `fstab`{{}}, run
`findmnt --verify`{{}} and `mount -a`{{}} **before** rebooting. `mount -a`{{}}
mounts everything in the file that is not already mounted, so it surfaces a bad
entry while you still have a shell. Rebooting to find out is how a two-minute
edit becomes a rescue-media afternoon.

`/etc/fstab`{{}} on this box has an entry for a device that does not exist,
with no `nofail`{{}} and a pass of `2`{{}}. It would not boot.

### Task

Make the box survive the missing device:

1. Keep the `/mnt/backup`{{}} entry. Deleting it is not the fix.
2. Make a missing device **not block boot**.
3. Make sure the missing device is **not fsck'd** either.

<details><summary>Tip</summary>

```
man 5 fstab
findmnt --verify
```{{exec}}

`fstab(5)`{{}} describes all six columns. `findmnt --verify`{{}} will still
report the device as unreachable, because it genuinely is; what it must not
report is a parse error.

</details>

<details><summary>Solution</summary>

```
sed -i 's|\(/mnt/backup[[:space:]]\+ext4[[:space:]]\+\)defaults\([[:space:]]\+0[[:space:]]\+\)2|\1defaults,nofail\20|' /etc/fstab
findmnt --verify
```{{copy}}

</details>
