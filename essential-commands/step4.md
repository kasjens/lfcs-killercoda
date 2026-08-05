# Determine application and service specific constraints

Resource limits reach a process by two separate routes, and picking the wrong
one is the classic failure.

The old route is PAM. At login, `pam_limits`{{}} reads
`/etc/security/limits.conf`{{}} and applies limits to that session, which
everything the session starts then inherits. This governs a person at a shell.

The new route is systemd. A service started by systemd **never logged in**, so
PAM never ran for it and `limits.conf`{{}} does not apply. Its constraints come
from directives in the unit, documented on their own page,
`systemd.resource-control(5)`{{}}, which covers `MemoryMax=`{{}},
`CPUQuota=`{{}} and the rest. If you set a limit in `limits.conf`{{}} and the
service ignores it, that is why.

The other half of this step is *where* to put the directives. Editing a unit
file directly works until the package that shipped it is upgraded. systemd
reads a drop-in directory beside the unit, `<unit>.d/`{{}}, and merges any
`.conf`{{}} in it over the top. That survives upgrades and keeps your change
separable, so it is the answer whenever the question is "add a setting to an
existing unit".

### Task

Constrain `hello.service`{{}} **without editing the unit file**:

1. `MemoryMax=`{{}} **512M**
2. `CPUQuota=`{{}} **20%**

The check fails if those directives appear in `hello.service`{{}} itself.

<details><summary>Tip</summary>

```
man 5 systemd.resource-control
man 5 systemd.unit
```{{exec}}

`systemd.unit(5)`{{}} describes the drop-in directory and the exact naming it
expects, under the part about how unit files are loaded. The directory name is
derived from the unit name, and the file inside needs the right section header
or the directives are ignored silently.

`systemctl cat hello.service`{{}} shows the unit and every drop-in merged,
which is the quickest way to confirm yours was picked up.

</details>

<details><summary>Solution</summary>

```
mkdir -p /etc/systemd/system/hello.service.d
cat > /etc/systemd/system/hello.service.d/limits.conf <<'EOF'
[Service]
MemoryMax=512M
CPUQuota=20%
EOF
systemctl daemon-reload
```{{copy}}

</details>
