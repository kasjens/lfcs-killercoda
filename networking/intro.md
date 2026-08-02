# Networking

The heaviest LFCS domain, 25% of the exam, and eight competencies: addressing
and resolution, time synchronisation, monitoring, OpenSSH, packet filtering and
NAT, static routing, bridges and bonds, and reverse proxies.

Every step is real work on this box. All of it happens on **dummy interfaces**
you create, never on the interface carrying your session, so there is nothing
you can do here that disconnects you. The terminal prints the name of the real
one when it is ready, so you know which to leave alone.

Two steps configure a daemon that has nothing to talk to: chrony has no time
server and nginx has no backend. Those check that the configuration is correct
and that the daemon accepts it, which is what `chronyd -Q` and `nginx -t` are
for. Both steps say so.

> Do **LFCS prep 1: find it in the man pages** first if you have not. `ip` alone
> has a page per subcommand, and knowing that `man ip-route` exists is worth
> more here than in any other domain.

You are root.
