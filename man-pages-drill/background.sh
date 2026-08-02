#!/bin/bash
# Two jobs: put real man pages on the box, and install the drill.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less python3

# The pages the drill asks about, so any answer can be settled on the spot.
apt-get install -y -qq nfs-common quota acl lvm2 nftables chrony sudo openssh-server
apt-get install -y -qq --reinstall coreutils util-linux passwd login mount cron

mandb -q

# Assets land asynchronously, so wait for them rather than racing.
for _ in $(seq 1 90); do
  [ -f /root/drill.py ] && [ -f /root/bank.json ] && break
  sleep 1
done

mkdir -p /usr/local/lib/lfcs-drill
if [ -f /root/drill.py ] && [ -f /root/bank.json ]; then
  mv /root/drill.py /root/bank.json /usr/local/lib/lfcs-drill/
  chmod +x /usr/local/lib/lfcs-drill/drill.py
fi

cat > /usr/local/bin/drill <<'WRAPPER'
#!/bin/bash
exec python3 /usr/local/lib/lfcs-drill/drill.py "$@"
WRAPPER
chmod +x /usr/local/bin/drill

touch /tmp/scenario-ready
