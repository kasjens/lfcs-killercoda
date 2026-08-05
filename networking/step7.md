# Configure bridge and bonding devices

Both take several interfaces and present them as one, for opposite reasons.

A **bridge** is a software switch. Frames arriving on one member are forwarded
to the others by MAC address. This is how virtual machines and containers reach
the physical network: the host bridges a real interface with the virtual ones.
Members of a bridge do not have their own IP addresses; the bridge does.

A **bond** aggregates several interfaces into one for redundancy or throughput.
The mode determines how:

- **`active-backup`{{}}** uses one member and fails over. It needs no
  cooperation from the switch at all, which makes it the safe answer when you
  cannot configure the other end.
- **`802.3ad`{{}}** (LACP) genuinely aggregates bandwidth, and requires the
  switch to be configured to match. Set this against a switch that is not
  expecting it and you get a broadcast storm or a dead link.
- **`balance-rr`{{}}** round-robins packets, which can reorder them and upset
  TCP.

The mechanism for both is the same:
`ip link set <member> master <virtual>`{{}}. The word is `master`{{}}, which is
also how you check with `ip link show`{{}}, and a member with no master is
simply not enslaved however you configured it.

One rule that catches people: **an interface must be down before it can be
enslaved to a bond**, and it must not carry an IP address of its own. The
address belongs to the bond. A bridge is more forgiving, but the same discipline
applies.

`ip -d link show <name>`{{}} prints the driver-specific detail, which is the
only way to confirm a bond's mode after the fact.

### Task

Two spare dummy interfaces, `dummy1`{{}} and `dummy2`{{}}, are already present.

1. A bridge **`br0`{{}}** with **`dummy1`{{}}** as a member, bridge up.
2. A bond **`bond0`{{}}** in **`active-backup`{{}}** mode, with
   **`dummy2`{{}}** as a member, bond up.

<details><summary>Tip</summary>

```
man ip-link
```{{exec}}

`ip link add ... type bond mode <mode>`{{}} sets the mode at creation. Confirm
with `ip -d link show bond0`{{}}, which prints the mode.

Remember to bring `dummy2`{{}} down before enslaving it.

</details>

<details><summary>Solution</summary>

```
ip link add br0 type bridge
ip link set dummy1 master br0
ip link set br0 up
ip link add bond0 type bond mode active-backup
ip link set dummy2 down
ip link set dummy2 master bond0
ip link set bond0 up
```{{copy}}

</details>
