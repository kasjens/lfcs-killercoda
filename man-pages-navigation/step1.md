# Sections

Nine numbered sections. Four matter for LFCS:

| Section | Holds |
|---|---|
| **1** | user commands |
| **5** | **file formats** — the syntax of things you edit |
| **7** | overviews and conventions |
| **8** | system administration commands |

The split that costs people marks is 5 against 8. `mount` is a command you run,
so it is in 8. `fstab` is a file you edit, so it is in 5. The same name can live
in both: `crontab(1)` tells you how to edit your crontab, `crontab(5)` tells you
what the five time fields mean.

### Task

Three questions. Record all three, then press **Check**.

**1.** Which section documents the **format of `/etc/fstab`**, the six columns
rather than the mount command?

**2.** Which section holds `chage`? Think about who is allowed to run it before
you guess.

**3.** `sysctl` appears in two sections. Which one is the **command you run** to
change a kernel parameter at runtime?

Record just the numbers:

```
answer 1 <number>
answer 2 <number>
answer 3 <number>
```{{copy}}

`answer` only writes the file the check reads, so plain redirection does the
same job:

```
echo <number> > /tmp/answers/1
```{{copy}}

<details><summary>Tip</summary>

`whatis` lists every section a name appears in, which answers all three:

```
whatis fstab
whatis chage
whatis sysctl
```{{exec}}

For question 3, read the two one-line descriptions. One of them is a system
call, which is a thing programs use, not a thing you run.

</details>

<details><summary>Solution</summary>

```
answer 1 5
answer 2 1
answer 3 8
```{{copy}}

5 is file formats, so the fstab layout is there. `chage` is 1 because an
unprivileged user can run `chage -l` on themselves. `sysctl` is in 2 as a
system call and 8 as the command you run.

</details>
