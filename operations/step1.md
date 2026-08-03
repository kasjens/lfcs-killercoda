# Configure kernel parameters, persistent and non-persistent

Two different things, and a task that says "and make it persistent" wants both.

**Non-persistent** is `sysctl -w key=value`, or writing to the matching file
under `/proc/sys`. It takes effect immediately and is gone at reboot. The path
and the key are the same thing with different separators:
`net.ipv4.ip_forward` is `/proc/sys/net/ipv4/ip_forward`.

**Persistent** is a file read at boot. `/etc/sysctl.conf` still works but is
package owned; the modern place is a drop-in in `/etc/sysctl.d/`. Files there
are read in lexical order, which is why they are conventionally numbered, and
later files win, so `99-` beats `10-`.

Applying a file with `sysctl -p <file>` takes effect immediately, which is how
you avoid a reboot after editing one. `sysctl -a` lists everything currently set, and piping that
through `grep` beats remembering exact key names.

Two that come up constantly. `net.ipv4.ip_forward` turns the box into a router
and is required before any NAT rule does anything at all. `vm.swappiness`
biases the kernel towards or away from swapping, and lowering it is the usual
tuning on a box with plenty of RAM.

### Task

1. Turn on IPv4 forwarding **right now**.
2. Make it survive a reboot, in a **drop-in** under `/etc/sysctl.d/`, not by
   editing `/etc/sysctl.conf`.
3. In the same file, set **`vm.swappiness`** to **10**.

<details><summary>Tip</summary>

```
man 8 sysctl
man 5 sysctl.d
```{{exec}}

`sysctl.d(5)` explains the ordering rules and the naming convention. Check the
live value with `sysctl -n net.ipv4.ip_forward`.

</details>

<details><summary>Solution</summary>

```
sysctl -w net.ipv4.ip_forward=1
printf 'net.ipv4.ip_forward = 1\nvm.swappiness = 10\n' > /etc/sysctl.d/99-lfcs.conf
sysctl -p /etc/sysctl.d/99-lfcs.conf
```{{copy}}

</details>
