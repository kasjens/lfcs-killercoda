# Troubleshoot disk space issues

Two commands answer "where did the space go", and they answer different
questions. One reports per filesystem, reading the filesystem's own accounting,
so it is instant. The other walks a directory tree adding up what it finds, so
it is slow on a large tree and it only sees files that still have a name.

That difference is the whole of the classic failure. A filesystem reports 100%
full, the directory walk adds up to far less, and the gap never resolves. The
space belongs to a file that was deleted while a process still had it open. The
name is gone so the tree walk cannot see it, but the blocks are not freed until
the last file descriptor closes.

Finding it needs a third tool, the one that lists open files. Its page is in
section 8, and it will show the deleted file still held open, along with the
process to restart.

### Task

**17.** The command that reports free space per filesystem.

**18.** The command that summarises space used by a directory tree.

**19.** The command that lists open files, including a deleted file still held
open by a process.

**20.** The section that command's page lives in.

```
answer 17 <command>
answer 18 <command>
answer 19 <command>
answer 20 <number>
```{{copy}}

<details><summary>Tip</summary>

```
man -k 'open files'
man -k 'disk space'
```{{exec}}

Worth reading once for real, since it is the actual exam move: inside the
open-files page, search for `deleted` to see how the state is reported.

</details>
