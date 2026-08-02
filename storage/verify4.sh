#!/bin/bash
# Step 4: remote filesystems. There is no NFS server on this box, so this
# checks the entry is correct rather than that it mounts. The step says so.
bad=0
note() { echo "$1" >&2; bad=1; }
mp=/mnt/shared

line="$(grep -E "^[^#]*[[:space:]]${mp}[[:space:]]" /etc/fstab 2>/dev/null | tail -n1)"
[ -n "$line" ] || { echo "no /etc/fstab entry for $mp" >&2; exit 1; }

src="$(printf '%s' "$line" | awk '{print $1}')"
type="$(printf '%s' "$line" | awk '{print $3}')"
opts="$(printf '%s' "$line" | awk '{print $4}')"

# host:/export, which is what distinguishes a remote source from a local one.
printf '%s' "$src" | grep -qE '^[^/:]+:/' \
  || note "the source is '$src', not the host:/export form an NFS mount needs"

case "$type" in
  nfs|nfs4) ;;
  "") note "the entry has no filesystem type" ;;
  *) note "the filesystem type is '$type', not nfs" ;;
esac

# Without _netdev the boot can try to mount before the network is up and hang.
printf '%s' "$opts" | grep -q '_netdev' \
  || note "the options do not include _netdev, so boot may try to mount this before the network is up"

# noauto keeps a box that cannot reach the server from failing to boot.
printf '%s' "$opts" | grep -q 'noauto' \
  || note "the options do not include noauto"

[ -d "$mp" ] || note "the mount point $mp does not exist"

exit "$bad"
