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

# Step 7 reads dockerd(8), greps the shell completion for the log driver's
# options and restarts docker.service, so the engine has to be on the box --
# and specifically Ubuntu's packaging of it. docker.io ships a completion that
# spells the options out; upstream docker-ce ships one that asks the binary at
# runtime and contains no values at all, so the tip's grep would come back
# empty there. Keying off the option list rather than off dockerd covers both
# an image with no docker and an image with the wrong packaging of it.
grep -q max-size /usr/share/bash-completion/completions/docker 2>/dev/null \
  || apt-get install -y -qq docker.io

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

# Steps 6 and 8 are lookups that record answers with this, so it has to exist.
mkdir -p /tmp/answers
cat > /usr/local/bin/answer <<'HELPER'
#!/bin/bash
if [ "$#" -lt 2 ]; then
  echo "usage: answer <question number> <your answer>" >&2
  echo "  writes the answer to /tmp/answers/<question number>," >&2
  echo "  which is exactly what 'echo <answer> > /tmp/answers/<n>' does" >&2
  exit 1
fi
mkdir -p /tmp/answers
n="$1"; shift
printf '%s\n' "$*" > "/tmp/answers/$n"
echo "question $n recorded: $*"
HELPER
chmod +x /usr/local/bin/answer

touch /tmp/scenario-ready
