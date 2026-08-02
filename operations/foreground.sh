echo "Installing man pages and tooling, and planting two faults to find."
while [ ! -f /tmp/scenario-ready ]; do sleep 1; done
echo

if man -w 1 virsh 2>/dev/null | grep -q '^/'; then
  echo "Man pages are live. Try: man -k apparmor"
else
  echo "WARNING: man pages did not install. /var/log/killercoda has the reason."
fi

echo
echo "Two things on this box are deliberately broken: a unit file and an"
echo "/etc/fstab entry. Steps 2 and 5 are about finding and fixing them."
