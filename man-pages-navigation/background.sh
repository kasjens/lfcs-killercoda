#!/bin/bash
# Killercoda's ubuntu image ships with documentation stripped, which would make
# a man page scenario impossible. Undo that, then install the packages whose
# pages the six steps actually ask about.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less quota nfs-common

# Already installed, but without their documentation.
apt-get install -y -qq --reinstall coreutils util-linux passwd login mount cron

# apropos and whatis read an index, not the pages. No index, no results.
mandb -q

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
