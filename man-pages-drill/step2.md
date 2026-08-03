# SECTIONS, part 2 of 2

Section numbers are the first decision in every lookup. Get the number right
and the page is one command away; get it wrong and you read the wrong thing
convincingly. 1 is user commands, 5 is file formats, 8 is administration, and
7 is the odd one for things that are neither.

### Task

7 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**11.** *sudoers, two pages*

You need the sudoers file syntax, and separately the tool that edits it
safely. Type both commands. (the file syntax)

**12.** *the second part of the same item* (the safe editor)

**13.** *timer units*

You are writing a .timer unit and need OnBootSec, Persistent and Unit. Type
the command.

**14.** *the directive you cannot find*

You need User=, Environment= and WorkingDirectory= for a service unit, and
they are not in systemd.service(5). Type the page that has them.

**15.** *resource limits*

A task asks you to raise nofile for a user in /etc/security/limits.conf. Type
the command for the syntax.

**16.** *sshd keywords*

You need PermitRootLogin, AllowUsers and the Match block syntax. Type the
command.

**17.** *NFS mount options*

You are mounting an export and need vers=, soft, hard, timeo and retrans. Type
the command.

```
answer 11 <your answer>
answer 12 <your answer>
answer 13 <your answer>
answer 14 <your answer>
answer 15 <your answer>
answer 16 <your answer>
answer 17 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**11.** Grammar in 5, the editor that enforces it in 8.

**12.** Grammar in 5, the editor that enforces it in 8.

**13.** Unit files are files, so they are section 5, one page per unit type.

**14.** How it runs is in .service. What it runs as is in .exec.

**15.** The file has a section 5 page named exactly like the file.

**16.** The d is for daemon. sshd_config for the server, ssh_config for you.

**17.** Mount options are read out of a file, so they are documented in 5.

</details>

<details><summary>Solution</summary>

```
answer 11 man 5 sudoers
answer 12 man 8 visudo
answer 13 man 5 systemd.timer
answer 14 man 5 systemd.exec
answer 15 man 5 limits.conf
answer 16 man 5 sshd_config
answer 17 man 5 nfs
```{{copy}}

**11.** sudoers(5) carries the user-host-runas grammar and the NOPASSWD tag.
visudo(8) carries -c for a syntax check and -f for an alternate file. Two
pages, two jobs.

**12.** sudoers(5) carries the user-host-runas grammar and the NOPASSWD tag.
visudo(8) carries -c for a syntax check and -f for an alternate file. Two
pages, two jobs.

**13.** Every systemd unit type has its own section 5 page: systemd.unit,
systemd.service, systemd.timer, systemd.mount, systemd.socket. The directives
for [Timer] are only in systemd.timer(5).

**14.** systemd.service(5) documents Type=, ExecStart= and Restart=.
Everything about the execution environment — user, group, environment, working
directory, sandboxing — was factored out into systemd.exec(5) because
[Service], [Socket] and [Mount] all share it.

**15.** limits.conf(5) has the four-column domain/type/item/value table and
the full item list. pam_limits(8) is the module that reads it — a different
page, and not the one with the syntax.

**16.** sshd_config(5) is the server keyword list. ssh_config(5) is the client
one, and mixing them up costs you the task. sshd(8) is the daemon itself.

**17.** nfs(5) is the mount option reference, and it is one of the highest-
value pages on the whole exam. mount(8) points you here rather than repeating
it.

</details>
