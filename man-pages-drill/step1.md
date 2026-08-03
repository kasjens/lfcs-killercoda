# SECTIONS, part 1 of 2

Section numbers are the first decision in every lookup. Get the number right
and the page is one command away; get it wrong and you read the wrong thing
convincingly. 1 is user commands, 5 is file formats, 8 is administration, and
7 is the odd one for things that are neither.

### Task

10 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**1.** *fstab - the six fields*

You need the field layout of /etc/fstab. Type the command that opens the right
page.

**2.** *admin commands*

useradd, mount, lvextend and vgcreate all share one man section. Type its
number.

**3.** *crontab - the five time fields*

You have forgotten the order of the five cron time fields. Type the command
that shows them.

**4.** *chage - the section trap*

Password aging with chage. Type the section number its page lives in.

**5.** *passwd - the seven fields*

You need the colon-separated field layout of /etc/passwd, not the command that
changes passwords. Type it.

**6.** *read every match*

Show every man page named passwd, one after another, section 1 then section 5.
Type the command.

**7.** *sysctl - three sections deep*

sysctl exists in 2 (the syscall), 5 (sysctl.conf) and 8 (the command). Open
the page for the command you run at a shell.

**8.** *sysctl.d drop-ins*

A task wants a kernel parameter to survive reboot via a drop-in file. You need
the naming and precedence rules for /etc/sysctl.d/. Type the command.

**9.** *the filesystem layout*

You want the reference for what belongs in /srv vs /var vs /usr/share. Type
the command.

**10.** *device files*

Type the section number that documents special files under /dev, such as loop
and null.

```
answer 1 <your answer>
answer 2 <your answer>
answer 3 <your answer>
answer 4 <your answer>
answer 5 <your answer>
answer 6 <your answer>
answer 7 <your answer>
answer 8 <your answer>
answer 9 <your answer>
answer 10 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**1.** Five letters in F-I-E-L-D. If you edit the file, read 5.

**2.** 8 looks like a padlock stacked twice. Locked = root only.

**3.** Five fields, section five.

**4.** You can chage yourself, so it is a user command. Self-service means
section 1.

**5.** Same word, two jobs. 1 does it, 5 describes it.

**6.** -a for all the way through.

**7.** Run it at a prompt with sudo, look in 8.

**8.** Any /etc/*.d directory has its own section 5 page named after the
directory.

**9.** hier as in hierarchy. Overviews live in 7.

**10.** 1 user, 2 syscall, 3 library, 4 device, 5 file format, 6 games, 7
overview, 8 admin.

</details>

<details><summary>Solution</summary>

```
answer 1 man 5 fstab
answer 2 8
answer 3 man 5 crontab
answer 4 1
answer 5 man 5 passwd
answer 6 man -a passwd
answer 7 man 8 sysctl
answer 8 man 5 sysctl.d
answer 9 man 7 hier
answer 10 4
```{{copy}}

**1.** fstab(5) is the file format. mount(8) is the command. Plain `man fstab`
happens to land on 5 here because nothing else claims the name, but typing the
number is the habit that saves you when a name lives in two sections.

**2.** Section 8 is system administration commands — the ones that normally
need root. Almost every LFCS task verb lives here.

**3.** crontab(1) documents the *command* — how to edit and list. crontab(5)
documents the *file* — the five fields, @reboot, ranges and steps. Bare `man
crontab` gives you 1 and leaves you no wiser.

**4.** chage is section 1, not 8, even though it reads like an admin tool —
because an unprivileged user may run `chage -l` on their own account. useradd,
usermod and userdel are 8; chage, passwd and gpasswd are 1.

**5.** passwd(1) changes a password. passwd(5) describes the file. This is the
cleanest example of why the number matters — the same name, two entirely
different pages, and bare `man passwd` gives you the wrong one.

**6.** -a walks all matches instead of stopping at the lowest-numbered one.
Quit one page with q and the next opens. Useful when you know the name but not
which section holds the thing you want.

**7.** sysctl(8) documents -w, -p, -a and --system. sysctl.conf(5) documents
the file syntax. sysctl(2) is the C system call and is no use to you on this
exam.

**8.** sysctl.d(5) is where the .conf suffix requirement, the numeric-prefix
ordering, and the /etc over /usr/lib precedence are written down. This page
answers more Operations Deployment questions than sysctl(8) does.

**9.** hier(7) is the filesystem hierarchy overview. Section 7 holds
conventions and overviews rather than commands or file formats.

**10.** Section 4 is devices and special files. You rarely need it on LFCS,
but knowing it exists stops you hunting through 5 and 8 for loop(4).

</details>
