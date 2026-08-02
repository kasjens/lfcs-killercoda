# Where does the page live?

`man -w` prints the location of a page's source file instead of rendering it.
Useful when you want to `grep` or `zcat` the raw page, and useful for confirming
which of several installed copies you are actually reading.

```
man -w 5 fstab
```{{exec}}

Related: `whereis` gives you binary, source and manual locations at once, and
`type` tells you whether the thing is a shell builtin — in which case it has no
page of its own and you want `man bash` instead.

```
type cd
whereis mount
```{{exec}}

### Task

Record the **full path** of the source file for the `nfs(5)` page.

```
answer 5 <full path>
```{{copy}}

<details><summary>Tip</summary>

The section number goes before the name, the same as with `man`.

</details>
