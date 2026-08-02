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
