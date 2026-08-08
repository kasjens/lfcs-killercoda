# Configure packet filtering, port redirection and NAT

`nftables`{{}} replaced iptables. One tool, `nft`{{}}, one page, `nft(8)`{{}},
and a structure worth understanding rather than copying.

A **table** holds chains and has a family: `inet`{{}} covers IPv4 and IPv6 at
once, which is why you want it. A **chain** attaches to a **hook** in the
packet path, with a **type** and a **priority**, and for filtering it also has
a **policy**, the verdict for anything no rule matched.

The hooks that matter: `input`{{}} for traffic to this box, `forward`{{}} for
traffic through it, `output`{{}} for traffic from it, `prerouting`{{}} for DNAT
and `postrouting`{{}} for SNAT and masquerade.

Two rules you must not omit from a `policy drop`{{}} input chain, and the
reason each exists.

**`ct state established,related accept`{{}}** comes first. Filtering is
stateful. Without this the reply to your own outbound connection is an
unsolicited inbound packet and gets dropped, so the box appears to have no
network at all.

**`iif lo accept`{{}}.** Plenty of services talk to themselves over loopback,
and dropping that breaks things that have nothing to do with the network.

Then accept what you meant to allow. Forgetting `dport 22`{{}} on a remote box
ends the session and the exam question with it.

**Masquerade** is source NAT where the source address is whatever the outgoing
interface currently has, which is what you want when that address is not fixed.
It belongs in `postrouting`{{}}, because the routing decision has to have
happened before you know which interface, and therefore which address, applies.
Use `oifname "name"`{{}} rather than `oif name`{{}}: the string form does not
require the interface to exist when the rule is added, so the ruleset survives
a reboot where the device appears later.

Rules made with `nft`{{}} are lost at reboot; `/etc/nftables.conf`{{}} and the
`nftables`{{}} service are what make them persist.

### Task

A `policy drop`{{}} input chain on this box would drop the connection the
**Check** button arrives over, which is the mistake this step warns about,
committed against the machine you are reading this on. So the ruleset goes in a
network namespace of its own, `lfcs`{{}}, already created for you. It is a real
kernel ruleset, read back with `nft`{{}}, it just is not this box's.

```
ip netns exec lfcs bash
```{{exec}}

Everything below happens in that shell. `exit`{{}} returns you to the box.
`dummy0`{{}} is not in the namespace, which is exactly why rule 5 names the
interface as a string.

Build a ruleset:

1. An **inet** table with an **input** chain, hook input, **policy drop**.
2. Accept **established and related** connections.
3. Accept everything on **loopback**.
4. Accept **TCP port 22**.
5. An **ip nat** table with a **postrouting** chain that **masquerades**
   traffic leaving `dummy0`{{}}.

<details><summary>Tip</summary>

```
man nft
```{{exec}}

The page's synopsis section shows chain creation with the hook, priority and
policy in braces. Quote the braces so your shell does not eat them.

`nft list ruleset`{{}} prints everything you have built, and is how the check
reads it too. If it prints nothing, you are on the box rather than in the
namespace: either go back in, or put `ip netns exec lfcs`{{}} in front of the
command.

</details>

<details><summary>Solution</summary>

Prefixed, so it runs from the box or from inside the namespace either way.

```
ip netns exec lfcs nft add table inet filter
ip netns exec lfcs nft 'add chain inet filter input { type filter hook input priority 0; policy drop; }'
ip netns exec lfcs nft add rule inet filter input ct state established,related accept
ip netns exec lfcs nft add rule inet filter input iif lo accept
ip netns exec lfcs nft add rule inet filter input tcp dport 22 accept
ip netns exec lfcs nft add table ip nat
ip netns exec lfcs nft 'add chain ip nat postrouting { type nat hook postrouting priority 100; }'
ip netns exec lfcs nft add rule ip nat postrouting oifname "dummy0" masquerade
```{{copy}}

</details>
