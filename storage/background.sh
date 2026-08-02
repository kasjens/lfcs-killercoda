#!/bin/bash
# Ubuntu images ship with documentation stripped, which would make a man page
# scenario impossible. Undo that, install the storage tooling, and attach two
# spare block devices so LVM and mkfs have something real to work on.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less

apt-get install -y -qq lvm2 xfsprogs nfs-common autofs sysstat quota
apt-get install -y -qq --reinstall util-linux mount coreutils e2fsprogs

mandb -q

# Two spare disks, backed by files. Killercoda gives one root filesystem and no
# second disk, so loop devices are how this domain gets something to partition
# without touching the box's own storage.
mkdir -p /srv/disks
for n in 1 2; do
  img="/srv/disks/spare$n.img"
  [ -f "$img" ] || dd if=/dev/zero of="$img" bs=1M count=512 status=none
  losetup --find --show "$img" >> /tmp/lfcs-spares
done

touch /tmp/scenario-ready
