# Monitor and troubleshoot networking

`ss`{{}} replaced `netstat`{{}} and is faster because it reads kernel
structures directly rather than walking `/proc`{{}}. The flags worth having in
your fingers:

- **`-t`{{}}** TCP, **`-u`{{}}** UDP. Without one of these you get every socket
  family including UNIX sockets, which is rarely what you want.
- **`-l`{{}}** listening only. The default shows established connections
  instead, and "what is listening" is the more common question.
- **`-n`{{}}** numeric. Without it `ss`{{}} resolves ports to service names and
  addresses to hostnames, which is slow and hides the number you are looking
  for. `:ssh`{{}} is less useful than `:22`{{}} when you are checking a port
  change took effect.
- **`-p`{{}}** the owning process. This one needs privilege; as an ordinary
  user the column is silently blank rather than an error.

So `ss -tulpn`{{}} is the combination, and it is worth memorising as a unit.

The order things fail in is worth knowing too. If a service is unreachable,
check it is **listening** before you touch the firewall, and check **which
address** it is listening on. A daemon bound to `127.0.0.1`{{}} is invisible
from the network no matter how open the firewall is, and that is a far more
common cause than filtering.

For the layers below, `ip -s link`{{}} shows per-interface errors and drops,
and `tcpdump -i <if> -nn`{{}} shows whether packets arrive at all.

### Task

Capture the listening sockets to **`/root/sockets.txt`{{}}**:

1. TCP **and** UDP.
2. Listening sockets only.
3. Numeric ports and addresses, not resolved names.
4. With the owning process shown.

<details><summary>Tip</summary>

```
man ss
```{{exec}}

All four are single-letter flags and can be combined into one word. The page
lists them in the first screen.

</details>

<details><summary>Solution</summary>

```
ss -tulpn > /root/sockets.txt
```{{copy}}

</details>
