# Configure user resource limits

A line in `limits.conf` has four fields, and the second is the one people get
wrong.

```
<domain>  <type>  <item>  <value>
```

`domain` is who it applies to: a username, a `@group`, or `*`. `type` is `soft`
or `hard`. `item` is what is being limited. `value` is the number.

Soft against hard is the part worth understanding rather than memorising. The
soft limit is what is actually enforced right now. The hard limit is the
ceiling the user is allowed to raise their own soft limit to. An unprivileged
user can raise soft up to hard and can lower hard, but can never raise hard.
So setting only a hard limit enforces nothing by itself, and setting a soft
limit above the hard one is rejected.

These limits are applied by a PAM module at login. That is the same reason
given in the Essential Commands domain for why a systemd service ignores them:
a service never logged in, so PAM never ran for it.

The two items that come up most are the cap on open file descriptors, which is
what a busy server actually runs out of, and the cap on the number of
processes, which is what stops a fork bomb.

### Task

**9.** The PAM module that applies `limits.conf`.

**10.** The field that holds `soft` or `hard`.

**11.** The item that caps open file descriptors.

**12.** The item that caps the number of processes.

```
answer 9 <module>
answer 10 <field name>
answer 11 <item>
answer 12 <item>
```{{copy}}

<details><summary>Tip</summary>

```
man 5 limits.conf
```{{exec}}

The page opens with the four field names in order, then lists every item below.
Question 10 wants the field's name as the page writes it, not the values it can
take.

</details>
