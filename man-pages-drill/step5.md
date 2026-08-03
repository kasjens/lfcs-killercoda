# BEYOND-MAN

Man pages are not the only documentation on the box. `/usr/share/doc`, package
file lists and systemd's own introspection all answer questions the manual
does not, and the exam allows every one of them.

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

<details><summary>Prefer it scored and shuffled?</summary>

The drill program is still installed. It picks items at random, keeps score
with lives and a streak, and `drill --review` repeats only what you did not
produce cold. It does not feed this step's check, so use it as extra practice
rather than instead.

```
drill -t beyond -n 8
```{{copy}}

</details>
