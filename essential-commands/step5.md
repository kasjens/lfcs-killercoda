# Troubleshoot disk space issues

Two commands answer "where did the space go", and they answer different
questions. `df`{{}} reports per filesystem, reading the filesystem's own
accounting, so it is instant. `du`{{}} walks a directory tree adding up what it
finds, so it is slow on a large tree and it only sees files that still have a
name.

That difference is the whole of the classic failure. A filesystem reports 100%
full, `du`{{}} adds up to far less, and the gap never resolves. The space
belongs to a file that was deleted while a process still had it open. The name
is gone so `du`{{}} cannot see it, but the blocks are not freed until the last
file descriptor closes. `lsof`{{}} shows it, marked deleted, along with the
process to restart. That is also why `rm`{{}} on a log a daemon is writing
frees nothing, and truncating it does.

For finding an offender the useful shape is: `du`{{}} to narrow to a directory,
then sort by size. `du -h`{{}} on its own prints every subdirectory unsorted,
which is unreadable on a real tree, so combine it with `sort -h`{{}} or use
`du -a`{{}} and sort that.

### Task

`/srv/data`{{}} is using more space than it should. One file is responsible.

1. Find it.
2. Reclaim the space.
3. Leave the other files in that directory alone.

The check confirms the offender is gone or truncated and that the small files
beside it survived, so deleting the directory does not count.

<details><summary>Tip</summary>

```
man du
man sort
```{{exec}}

`du -ah /srv/data | sort -h | tail`{{}} puts the biggest thing last. The
`-h`{{}} on `sort`{{}} is what makes it order `5M`{{}} after `900K`{{}} instead
of alphabetically.

</details>

<details><summary>Solution</summary>

```
du -ah /srv/data | sort -h | tail -5
rm /srv/data/archive.log
```{{copy}}

</details>
