#!/bin/bash
# Ubuntu images ship with documentation stripped, which would make a man page
# scenario impossible. Undo that, then install the networking tooling this
# domain asks about.
set -x

rm -f /etc/dpkg/dpkg.cfg.d/excludes
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq man-db manpages manpages-dev less

apt-get install -y -qq iproute2 nftables openssh-server chrony nginx \
  bridge-utils ifenslave tcpdump dnsutils traceroute
apt-get install -y -qq --reinstall iproute2 coreutils

mandb -q

# Step 5 filters on the interface the learner creates in step 1, and step 7
# needs spare interfaces to enslave. Dummy devices cost nothing and cannot
# disturb the box's real connectivity.
modprobe dummy 2>/dev/null
modprobe bonding 2>/dev/null
modprobe br_netfilter 2>/dev/null

# Step 7 says these two are already here and then asks for a bridge and a bond
# built out of them. They were never created, so the step could not be done at
# all: every command in it answered "Cannot find device". Up, because the rule
# the step teaches -- a member must be down before a bond will take it -- is
# only a lesson if the learner meets an interface that is up.
ip link add dummy1 type dummy 2>/dev/null
ip link add dummy2 type dummy 2>/dev/null
ip link set dummy1 up 2>/dev/null
ip link set dummy2 up 2>/dev/null

# Step 5 builds a default-drop input chain. On this box that also drops the
# connection the Check button arrives over, and the step reports a validation
# error rather than a result. So the ruleset gets a network namespace of its
# own. Still a real kernel ruleset, read back with nft, just not this box's.
ip netns add lfcs 2>/dev/null
ip netns exec lfcs ip link set lo up 2>/dev/null

# nginx listens on 80 by default, which collides with step 8's site on 8080
# only if someone changes it, but a running default server also makes `ss`
# output in step 3 more interesting.
systemctl enable --now nginx 2>/dev/null

touch /tmp/scenario-ready
