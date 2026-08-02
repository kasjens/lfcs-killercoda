#!/bin/bash
# Ubuntu images ship with documentation stripped, which would make a man page
# scenario impossible. Undo that, then install what this domain asks about and
# plant the two faults the learner has to find.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less

# libvirt-clients for virsh(1) and libvirtd(8), apparmor for the MAC step.
apt-get install -y -qq libvirt-clients libvirt-daemon-system apparmor apparmor-utils cron
apt-get install -y -qq --reinstall systemd procps util-linux apt

mandb -q

# Step 2's fault: a mistyped section header, which systemd ignores silently,
# and an ExecStart pointing at nothing.
cat > /etc/systemd/system/broken.service <<'UNIT'
[Unit]
Description=broken

[Servce]
ExecStart=/usr/bin/definitely-not-here
UNIT

# Step 3 needs the script its job will run.
mkdir -p /usr/local/bin
printf '#!/bin/sh\necho report\n' > /usr/local/bin/report.sh
chmod +x /usr/local/bin/report.sh

# Step 5's fault: an entry for a device that does not exist, with an fsck pass
# of 2 and no nofail, which is what turns a missing disk into a failed boot.
mkdir -p /mnt/backup
grep -q '/mnt/backup' /etc/fstab || \
  printf 'UUID=00000000-0000-0000-0000-000000000000 /mnt/backup ext4 defaults 0 2\n' >> /etc/fstab

mkdir -p /etc/docker /etc/apt/keyrings

touch /tmp/scenario-ready
