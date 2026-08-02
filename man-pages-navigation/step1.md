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

Which section documents the **format of `/etc/fstab`** — the six columns, not
the mount command?

Record just the number:

```
answer 1 <number>
```{{copy}}

<details><summary>Tip</summary>

`whatis` lists every section a name appears in:

```
whatis fstab
whatis crontab
```{{exec}}

</details>
