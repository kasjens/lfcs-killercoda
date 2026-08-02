echo "Installing man pages and storage tooling, and attaching two spare disks."
while [ ! -f /tmp/scenario-ready ]; do sleep 1; done
echo

# The base image may ship a stub /usr/bin/man that exits 0 while doing nothing,
# so check for a real page path rather than a zero exit code.
if man -w 8 lvcreate 2>/dev/null | grep -q '^/'; then
  echo "Man pages are live. Try: man -k volume"
else
  echo "WARNING: man pages did not install. /var/log/killercoda has the reason."
fi

# Steps 1 and 3 need a spare block device. Say so plainly if there is not one,
# because every other symptom of that is confusing.
if [ -s /tmp/lfcs-spares ] && [ -b "$(head -n1 /tmp/lfcs-spares)" ]; then
  echo "Spare disks attached:"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'loop|NAME'
else
  echo "WARNING: no spare block device could be attached, so steps 1 and 3"
  echo "cannot be completed on this backend."
fi
