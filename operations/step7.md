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

**Types matter as much as syntax, and the two rules are different.** Everything
inside `log-opts`{{}} is a string, because the daemon hands that map to the log
driver verbatim and never looks inside it — so `"3"`{{}} and not `3`{{}}. Every
other field is typed by the daemon, and `live-restore`{{}} is a real boolean, so
it takes a bare `true`{{}}. Quote it and you get a file that is valid JSON,
passes every syntax check you can run on it, and stops the daemon dead with
`cannot unmarshal string into Go struct field`{{}}. Parsing and starting are two
different tests, and the daemon only sits the second one.

`max-size`{{}} carries its unit: `10m`{{}} is ten megabytes, and a bare number
is bytes. The driver parses the suffix, not you.

`docker info`{{}} prints the effective configuration, which is how you confirm
a setting took rather than assuming.

### Task

Configure the engine in `/etc/docker/daemon.json`{{}}:

1. Log driver **`json-file`{{}}**.
2. Rotate at **10m** per file, keeping **3** files.
3. Keep containers running across a daemon restart.
4. Restart the engine so it reads the file, and confirm with `docker info`{{}}
   that it took.

The check parses the file as JSON first, so a trailing comma fails before
anything else is looked at, and it reads types as well as values: a quoted
`true`{{}} is rejected here for the same reason the daemon rejects it.

What the check cannot see is requirement 4, because it reads the file and not
the running daemon. That gap is deliberate. A correct config file on a daemon
that never reread it is the same failure as `nmcli con mod`{{}} without
`nmcli con up`{{}}, and it is the one the exam is actually built to catch.

<details><summary>Tip</summary>

The client and the daemon are different binaries in different sections, and
`/etc/docker/daemon.json`{{}} belongs to the daemon. `man docker`{{}} is the
client, and its ninety-odd `SEE ALSO`{{}} entries are all subcommands of it, so
the first move is to get section 1 out of the way:

```
man -k docker | grep -v '(1)'
man dockerd
```{{exec}}

That takes about 190 lines down to three, one of which is `dockerd(8)`{{}}.

Now the part the page will not tell you. `dockerd(8)`{{}} documents
`--log-opt`{{}} as "Logging driver specific options" and lists none of them,
because the keys belong to each log driver rather than to the daemon.
`max-size`{{}} appears in no docker man page at all. **When a page defers like
that, stop searching it and change source** — the shell completion has to know
the values in order to offer them:

```
grep -n max-size /usr/share/bash-completion/completions/docker
```{{exec}}

That lands on the line where the completion lists the `json-file`{{}} driver's
options, with the ones every driver shares defined a few lines above it.

Worth knowing where that works: the spelled-out list is Ubuntu's
`docker.io`{{}} packaging. Upstream's `docker-ce`{{}} ships a completion that
asks the binary at runtime instead, so it holds no option names at all and this
grep comes back empty. On that packaging nothing on the box has them, which
makes these two keys a pair to know rather than to find.

Then validate with `python3 -m json.tool /etc/docker/daemon.json`{{}},
remembering it only proves the JSON parses, not that the daemon will accept it.

</details>

<details><summary>Solution</summary>

```
cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null
cat > /etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true
}
JSON
python3 -m json.tool /etc/docker/daemon.json
systemctl restart docker
docker info | grep -iE "logging driver|live restore"
```{{copy}}

The `cp`{{}} is the habit, not the exercise: this file is trivial here and a
clobbered one somewhere else is a bad afternoon. `systemctl restart docker`{{}}
is requirement 4, and `docker info`{{}} is the only thing in the block that
proves any of it worked.

</details>
