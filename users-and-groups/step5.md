# Configure the system to use LDAP user and group accounts

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
else has to. It has its own configuration page in section 5.

Underneath, the client library that actually speaks the protocol has a
configuration file of its own, setting the server URI, the search base and TLS
behaviour. Two config files, two layers: one decides which sources are
consulted, the other decides how to reach the directory.

### Task

**17.** The page deciding which sources answer `passwd` and `group` lookups.
Page name, no section number.

**18.** The section that page lives in.

**19.** The configuration page for the caching daemon.

**20.** The configuration page for the LDAP client library.

```
answer 17 <page name>
answer 18 <number>
answer 19 <page name>
answer 20 <page name>
```{{copy}}

<details><summary>Tip</summary>

```
man -k 'name service'
man -k ldap | head -20
```{{exec}}

Questions 19 and 20 are both section 5 and both end in `.conf`. One is named
after a three-letter daemon, the other after the protocol.

</details>
