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
reads it too.

</details>

<details><summary>Solution</summary>

```
nft add table inet filter
nft 'add chain inet filter input { type filter hook input priority 0; policy drop; }'
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input iif lo accept
nft add rule inet filter input tcp dport 22 accept
nft add table ip nat
nft 'add chain ip nat postrouting { type nat hook postrouting priority 100; }'
nft add rule ip nat postrouting oifname "dummy0" masquerade
```{{copy}}

</details>
