# Set and synchronize system time using time servers

Time matters more than it looks. Kerberos, TLS certificates, log correlation
and scheduled jobs all break in confusing ways when a clock drifts, and the
symptoms never mention time.

`chrony` is the usual implementation now. Its configuration is one file, and
two directives carry most of the weight.

**`server` or `pool`.** A `server` line names one host. A `pool` line names a
DNS name that resolves to several, and chrony uses several of them. Either is
correct, and `iburst` on the line tells chrony to send a rapid burst at
startup, taking initial synchronisation from minutes down to seconds. Without
it a freshly booted box is wrong for a long time.

**`makestep`.** By default chrony *slews* the clock, speeding it up or slowing
it down slightly until it agrees. That keeps time monotonic, which matters to
databases, but correcting an hour by slewing takes days. `makestep` says: for
the first N updates, if the offset is bigger than X seconds, jump instead.
That is what makes a box with a badly wrong clock usable immediately after
boot.

`timedatectl` is the systemd-side view: it shows whether NTP synchronisation is
active and what the local timezone is. Timezone and synchronisation are
different things, and the exam asks about both.

There is no reachable time server on this box, so this step checks your
configuration and lets `chronyd -Q` judge it, rather than waiting for a sync
that cannot happen.

### Task

Configure chrony:

1. Use **`time.example.com`** as a time source, with a rapid initial burst.
2. Allow the clock to be **stepped** rather than slewed when the offset is
   large.

<details><summary>Tip</summary>

```
man 5 chrony.conf
```{{exec}}

Search the page for `iburst` and for `makestep`. Both are described with
examples, and `makestep` takes two arguments.

`chronyd -Q -f /etc/chrony/chrony.conf` looks like a dry run, and it does check
the file, but it also performs a real query. Against a server that does not
answer it sits there until it gives up, so it is not the quick syntax check it
appears to be.

</details>

<details><summary>Solution</summary>

```
cat >> /etc/chrony/chrony.conf <<'EOF'
server time.example.com iburst
makestep 1.0 3
EOF
```{{copy}}

</details>
