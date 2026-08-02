echo "Installing man pages and the drill. About a minute."
while [ ! -f /tmp/scenario-ready ]; do sleep 1; done
echo
if [ -x /usr/local/lib/lfcs-drill/drill.py ]; then
  echo "Ready.  drill --list  shows the topics."
else
  echo "The drill did not install. Say so on the scenario and use 'man -k' meanwhile."
fi

# The base image may ship a stub /usr/bin/man that exits 0 while doing nothing,
# so check for a real page path rather than a zero exit code.
if man -w 5 fstab 2>/dev/null | grep -q '^/'; then
  echo "Man pages are live. Try: man -k quota"
else
  echo "WARNING: man pages did not install. /var/log/killercoda has the reason."
fi
