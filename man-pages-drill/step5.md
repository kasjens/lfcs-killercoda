# BEYOND-MAN

Man pages are not the only documentation on the box. `/usr/share/doc`{{}},
package file lists and systemd's own introspection all answer questions the
manual does not, and the exam allows every one of them.

### Task

9 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**38.** *the other documentation tree*

man has nothing useful, but the package shipped a README and a sample config.
Type the directory you look in.

**39.** *what did this package install*

On a Debian-family host, list every file the nfs-common package installed.
Type the command.

**40.** *just the documentation*

On an RPM host, list only the documentation files belonging to chrony. Type
the command.

**41.** *three locations at once*

Find the binary, the source and the man page for nft in one command. Type it.

**42.** *builtin or binary*

You want to know whether cd is a shell builtin, an alias or a file on disk.
Type the command.

**43.** *which package owns this file*

A config file exists and you want the package it came from. Type the RPM
command, then the Debian one. (RPM host)

**44.** *the second part of the same item* (Debian host)

**45.** *the unit as loaded*

Print the unit file systemd is actually using for chronyd, including any drop-
in overrides. Type the command.

**46.** *every systemd directive*

You know the directive name but not which of the fifteen systemd pages defines
it. Type the command that opens the master index.

```
answer 38 <your answer>
answer 39 <your answer>
answer 40 <your answer>
answer 41 <your answer>
answer 42 <your answer>
answer 43 <your answer>
answer 44 <your answer>
answer 45 <your answer>
answer 46 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**38.** hier(7) says it plainly: documentation about installed programs.

**39.** -L for list files. Capital L, because lowercase -l lists packages.

**40.** q query, then d docs, l list all, c config.

**41.** which is one answer, whereis is three.

**42.** If type says builtin, the docs are in bash(1), under SHELL BUILTIN
COMMANDS.

**43.** rpm asks -qf, which file. dpkg asks -S, search.

**44.** rpm asks -qf, which file. dpkg asks -S, search.

**45.** cat the unit, not the file, and you get the overrides for free.

**46.** Lost in systemd? Ask the directives index which page owns the word.

</details>

<details><summary>Solution</summary>

```
answer 38 /usr/share/doc
answer 39 dpkg -L nfs-common
answer 40 rpm -qd chrony
answer 41 whereis nft
answer 42 type cd
answer 43 rpm -qf /etc/chrony.conf
answer 44 dpkg -S /etc/chrony.conf
answer 45 systemctl cat chronyd
answer 46 man 7 systemd.directives
```{{copy}}

**38.** Every packaged program may drop READMEs, changelogs and example
configs under /usr/share/doc/<package>/. Your exam notes list it as an allowed
reference alongside man, and it often holds a working sample config you can
copy rather than write.

**39.** dpkg -L lists a package's files, which is how you find its docs, its
unit files and its example configs when you do not know their paths.

**40.** -qd queries doc files only, so you skip the binaries and libraries.
-ql gives you everything, -qc gives you just the config files — that last one
is worth remembering too.

**41.** whereis returns binary, source and manual locations. which only
returns the executable, and type tells you whether the shell would even reach
a file.

**42.** This matters because builtins have no man page of their own — they are
documented inside bash(1). If type says builtin, stop looking for cd(1) and
search inside man bash instead.

**43.** Once you have the package name, dpkg -L or rpm -qd gets you to its
docs and examples. This is the two-step that turns an unfamiliar config file
into a documented one.

**44.** Once you have the package name, dpkg -L or rpm -qd gets you to its
docs and examples. This is the two-step that turns an unfamiliar config file
into a documented one.

**45.** systemctl cat prints the real file with its path, and appends every
/etc/systemd/system/*.d/ drop-in in order. Faster than hunting the path
yourself, and it shows you which overrides are live.

**46.** systemd.directives(7) is an index of every directive systemd
understands, each pointing at the page that documents it. There is also
systemd.index(7) for page names. These two save more time than any other
lookup on the systemd side.

</details>
