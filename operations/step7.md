# Configure container engines

The competency is configuring the **engine**, not running containers, and the
engine's behaviour comes from one JSON file: `/etc/docker/daemon.json`{{}}.

Two defaults there are worth changing on any real host.

**Log rotation.** The default `json-file`{{}} driver writes container output to
disk with **no size limit and no rotation**. A chatty container fills the disk,
and because the files live under `/var/lib/docker/containers`{{}}, the usual
suspects in `/var/log`{{}} look innocent. `max-size`{{}} and `max-file`{{}} in
`log-opts`{{}} bound it. This is the single most common cause of a full disk on
a container host, and it is one setting.

**live-restore.** By default, restarting the daemon stops every container it is
running. With `live-restore`{{}} set, containers keep running across a daemon
restart or upgrade. On anything you care about, this is the difference between
patching the engine and taking an outage to do it.

Two things about the file itself. It is **strict JSON**: no comments, no
trailing commas, and a malformed file means the daemon refuses to start, which
turns a config tweak into an outage. And it is only read at **daemon start**,
so an edit does nothing until you restart or reload it.

`docker info`{{}} prints the effective configuration, which is how you confirm
a setting took rather than assuming.

### Task

Configure the engine in `/etc/docker/daemon.json`{{}}:

1. Log driver **`json-file`{{}}**.
2. Rotate at **10m** per file, keeping **3** files.
3. Keep containers running across a daemon restart.

The check parses the file as JSON first, so a trailing comma fails before
anything else is looked at.

<details><summary>Tip</summary>

```
man docker
```{{exec}}

The log options are nested inside a `log-opts`{{}} object, and their values are
strings even when they look like numbers. Validate with
`python3 -m json.tool /etc/docker/daemon.json`{{}}.

</details>

<details><summary>Solution</summary>

```
cat > /etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true
}
JSON
```{{copy}}

</details>
