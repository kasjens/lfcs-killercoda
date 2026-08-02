# Configure the system to use LDAP user and group accounts

This is the one competency in this domain you cannot rehearse properly on a
single box, because it needs a directory server to talk to. So this step is
lookups rather than a task, and it is marked as such rather than pretending a
configuration file you never connect with is the same as the real thing.

Directory lookups are not a special case. They plug into the same mechanism
that already answers "who is uid 1000", the Name Service Switch.

One configuration file lists, per database, which sources are consulted and in
what order. The `passwd`, `group` and `shadow` databases each get a line, and
the sources are tried left to right. Adding a directory source to those lines
is what makes remote accounts visible to every program on the box, without any
of them being recompiled or even aware. That is why `id`, `ls -l` and `sudo`
all start resolving remote users at the same moment.

Something has to implement the source. The usual answer today is a daemon that
caches lookups and handles the connection, failover and credentials, so nothing
else has to. Underneath it, the client library that actually speaks the
protocol has a configuration file of its own, setting the server URI, the
search base and TLS behaviour.

Two config files, two layers: one decides which sources are consulted, the
other decides how to reach the directory.

### Task

Four lookups. Record each with the `answer` command, then press **Check**.

**1.** The page deciding which sources answer `passwd` and `group` lookups.
Page name, no section number.

**2.** The section that page lives in.

**3.** The configuration page for the caching daemon.

**4.** The configuration page for the LDAP client library.

```
answer 1 <page name>
answer 2 <number>
answer 3 <page name>
answer 4 <page name>
```{{copy}}

<details><summary>Tip</summary>

```
man -k 'name service'
man -k ldap | head -20
```{{exec}}

Questions 3 and 4 are both section 5 and both end in `.conf`. One is named
after a three-letter daemon, the other after the protocol.

</details>
