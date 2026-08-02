#!/bin/bash
# Ubuntu images ship with documentation stripped, which would make a man page
# scenario impossible. Undo that, then install the packages whose pages this
# domain asks about.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less

# The tools this domain covers: git, sysstat for iostat and sar, lsof, openssl.
apt-get install -y -qq git sysstat lsof openssl ca-certificates

# Already installed, but without their documentation.
apt-get install -y -qq --reinstall coreutils bash procps systemd libpam-modules

# apropos and whatis read an index, not the pages. No index, no results.
mandb -q

# The deploy account step 2's unit runs as, so User=deploy is not a dead
# reference the learner has no way to satisfy.
id deploy >/dev/null 2>&1 || useradd -m -s /bin/bash deploy

# Step 3 checks that sysstat collection was turned on, so it has to start off.
mkdir -p /etc/default
printf 'ENABLED="false"\n' > /etc/default/sysstat

# Step 5's disk space problem: one oversized file among small ones, so that
# deleting the directory is not a fix.
mkdir -p /srv/data
dd if=/dev/zero of=/srv/data/archive.log bs=1M count=200 status=none
echo 'started' > /srv/data/app.log
echo 'keep me' > /srv/data/notes.txt

# One helper the steps use to record answers, so verification is unambiguous.
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
