echo "Installing man pages and networking tooling. About a minute."
while [ ! -f /tmp/scenario-ready ]; do sleep 1; done
echo

# The base image may ship a stub /usr/bin/man that exits 0 while doing nothing,
# so check for a real page path rather than a zero exit code.
if man -w 8 ip-address 2>/dev/null | grep -q '^/'; then
  echo "Man pages are live. Try: man -k nftables"
else
  echo "WARNING: man pages did not install. /var/log/killercoda has the reason."
fi

# Everything here is done on dummy interfaces, so nothing you do should reach
# the box's real connectivity. Say which interface that is, so it is obvious
# what not to touch.
echo
echo "Your real interface, leave this one alone:"
ip -o -4 route show default | awk '{print "  " $5, "via", $3}'
