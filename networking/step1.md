# Configure IPv4 and IPv6 networking and hostname resolution

`ip`{{}} is one command with a page per object, and the pages are hyphenated
the way Git's are: `ip-address(8)`{{}}, `ip-route(8)`{{}}, `ip-link(8)`{{}}.
The bare `man ip`{{}} is only the index. Knowing this turns the whole
`iproute2`{{}} suite into something you can read under time pressure.

Three things about addressing that the old `ifconfig`{{}} habits get wrong.

**An interface can hold many addresses.** `ip addr add`{{}} adds, it does not
replace. There is no need to choose between IPv4 and IPv6, or between two
subnets, and `ip addr replace`{{}} is the one that overwrites.

**Adding an address does not bring the link up.** They are separate operations
on separate objects, address and link, which is why a correctly addressed
interface can still be dead.

**The prefix length is part of the address.** `10.9.9.10`{{}} without `/24`{{}}
is not an error, it silently means `/32`{{}}, and then nothing on the local
network is reachable.

Resolution is a separate mechanism again. `/etc/hosts`{{}} is a file, but
nothing reads it directly. The Name Service Switch decides that `hosts:`{{}}
lookups consult `files`{{}} before DNS, and that ordering in
`/etc/nsswitch.conf`{{}} is what makes a `hosts`{{}} entry win over a real DNS
record. `getent hosts <name>`{{}} asks through the switch, which is why it is
the honest test, and `ping`{{}} is not.

### Task

Work on a **dummy** interface, not your real one:

1. Create **`dummy0`{{}}** and bring it **up**.
2. Give it **`10.9.9.10/24`{{}}**.
3. Give it **`2001:db8::10/64`{{}}** as well.
4. Make **`app.lfcs.local`{{}}** resolve to `10.9.9.10`{{}}.

<details><summary>Tip</summary>

```
man ip-link
man ip-address
man 5 nsswitch.conf
```{{exec}}

Creating a dummy interface is `ip link add ... type dummy`{{}}. The types are
listed in `ip-link(8)`{{}} under `ip link add`{{}}.

Test with `getent hosts app.lfcs.local`{{}}, not with `ping`{{}}. Only
`getent`{{}} goes through the switch, so it tells you whether resolution works
rather than whether the host answers.

</details>

<details><summary>Solution</summary>

```
ip link add dummy0 type dummy
ip addr add 10.9.9.10/24 dev dummy0
ip -6 addr add 2001:db8::10/64 dev dummy0
ip link set dummy0 up
echo '10.9.9.10 app.lfcs.local app' >> /etc/hosts
```{{copy}}

</details>
