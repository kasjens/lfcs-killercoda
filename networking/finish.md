# Done

Eight tasks on a real box, covering the eight competencies that make up
Networking, 25% of the exam and the heaviest domain.

The moves worth keeping:

- **`ip` has a page per object.** `ip-link(8)`, `ip-address(8)`,
  `ip-route(8)`. The bare `man ip` is only the index, and knowing that saves
  more time here than anywhere else.
- **`ss -tulpn`** as one word. TCP and UDP, listening, numeric, with process.
- **Check it is listening before you touch the firewall.** A daemon bound to
  `127.0.0.1` is unreachable no matter how open the filter is, and that is the
  more common cause.
- **`sshd -t` and `nginx -t`.** Both validate their own configuration and exit.
  Use them before reloading anything, especially over a connection you would
  lose. `chronyd -Q` looks like the same thing and is not: it performs a real
  time query and hangs against a server that does not answer.

Six traps that were in here on purpose:

1. `ssh_config` and `sshd_config` differ by one letter and editing the wrong
   one changes nothing.
2. sshd takes the **first** occurrence of a keyword, not the last, and the
   `Include` for `sshd_config.d` sits at the top of the file.
3. `PermitRootLogin prohibit-password` still permits root login by key. Only
   `no` disallows it.
4. A `policy drop` input chain without `ct state established,related accept`
   drops the replies to your own traffic, so the box looks completely offline.
5. `oif` resolves the interface when the rule is added and fails if it does not
   exist yet; `oifname` matches the name as a string and survives a reboot.
6. An interface must be **down** before it can be enslaved to a bond, and the
   address belongs to the bond, not the member.

One domain left: operations and deployment, also 25%.
