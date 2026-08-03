#!/bin/bash
# One job: put real man pages on the box, so every answer can be settled here.
# Ubuntu images ship with documentation stripped, which would make a man page
# scenario impossible.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less quota nfs-common

# One question asks for the RPM equivalent of `dpkg -L`. The exam is
# distribution agnostic, so the question is fair, but without the package there
# is no rpm(8) to look it up in and the answer cannot be settled here.
apt-get install -y -qq rpm

# The pages the steps ask about, already installed but without their docs.
apt-get install -y -qq --reinstall coreutils util-linux passwd login mount cron \
  systemd procps

# apropos and whatis read an index, not the pages. No index, no results.
mandb -q

# The steps record answers with this, so it has to exist before step 1.
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
