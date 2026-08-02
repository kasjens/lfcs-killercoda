# Configure static routing

The kernel picks a route by **longest prefix match**: the most specific route
wins, regardless of the order rules were added. `0.0.0.0/0` is the default
route and it is simply the least specific one, which is why it is the fallback
without any special-casing.

`ip route` shows the table. Three route types are worth knowing.

**A gateway route**, `via <address> dev <interface>`, sends matching traffic to
a next hop. The gateway must be reachable on a directly connected subnet
already, or the kernel refuses the route with a "Nexthop has invalid gateway"
error. That error almost always means you added the route before the address.

**A device route** with `dev` and no `via` treats the destination as directly
attached, which is what point-to-point links and some tunnels need.

**A blackhole or unreachable route** discards traffic deliberately. `blackhole`
drops silently; `unreachable` drops and returns ICMP unreachable to the sender.
Both stop a range from following the default route out, which is the tidy way
to stop traffic to somewhere you should not be reaching. Doing this with a
firewall rule works too, but the routing table is where it belongs.

IPv6 is a separate table with the same commands: `ip -6 route`. Configuring
IPv4 and forgetting IPv6 is one of the easier ways to lose half a mark.

Routes added with `ip` are lost at reboot. Persisting them is distribution
specific, netplan or NetworkManager or systemd-networkd, which is exactly why
the exam is distribution agnostic about the runtime commands.

### Task

`dummy0` from step 1 is your local link.

1. Route **`192.0.2.0/24`** via **`10.9.9.254`** on **`dummy0`**.
2. Make **`198.51.100.0/24`** **unreachable**, so it does not follow the
   default route.
3. Route **`2001:db8:beef::/48`** out of `dummy0`.

<details><summary>Tip</summary>

```
man ip-route
```{{exec}}

The route types, including `unreachable` and `blackhole`, are listed near the
top of `ip-route(8)` under ROUTE TYPES.

If you get "Nexthop has invalid gateway", the address on `dummy0` is missing or
in a different subnet from the gateway you named.

</details>

<details><summary>Solution</summary>

```
ip route add 192.0.2.0/24 via 10.9.9.254 dev dummy0
ip route add unreachable 198.51.100.0/24
ip -6 route add 2001:db8:beef::/48 dev dummy0
```{{copy}}

</details>
