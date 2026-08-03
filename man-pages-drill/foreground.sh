echo "Installing man pages. About a minute."
while [ ! -f /tmp/scenario-ready ]; do sleep 1; done
echo

# The base image may ship a stub /usr/bin/man that exits 0 while doing nothing,
# so check for a real page path rather than a zero exit code. This is the only
# thing that should announce readiness.
if man -w 5 fstab 2>/dev/null | grep -q '^/'; then
  echo "Man pages are live. Try: man -k quota"
else
  echo "WARNING: man pages did not install. /var/log/killercoda has the reason."
fi
