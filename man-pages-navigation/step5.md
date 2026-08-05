# Where does the page live?

`man -w`{{}} prints the location of a page's source file instead of rendering
it. Useful when you want to `grep`{{}} or `zcat`{{}} the raw page, and useful
for confirming which of several installed copies you are actually reading.

```
man -w 5 fstab
```{{exec}}

Related: `whereis`{{}} gives you binary, source and manual locations at once,
and `type`{{}} tells you whether the thing is a shell builtin — in which case
it has no page of its own and you want `man bash`{{}} instead.

```
type cd
whereis mount
```{{exec}}

### Task

**13.** The **full path** of the source file for the `nfs(5)`{{}} page.

**14.** The `man`{{}} flag that prints that path instead of rendering the page.

**15.** The `man`{{}} flag that searches the **body** of every page rather than
just the one-line descriptions. Case matters here: the lowercase version is a
different search entirely.

Record 14 and 15 as the flag itself, leading dash included:

```
answer 13 <full path>
answer 14 <flag>
answer 15 <flag>
```{{copy}}

<details><summary>Tip</summary>

The section number goes before the name, the same as with `man`{{}}.

Questions 14 and 15 are both in `man man`{{}}. The long forms are accepted too,
and reading them is the fastest way to be sure which case does what:

```
man man
```{{exec}}

</details>

<details><summary>Solution</summary>

```
answer 13 $(man -w 5 nfs)
answer 14 -w
answer 15 -K
```{{copy}}

Let `man -w`{{}} tell you the path rather than typing it: the version number in
it changes between releases. `-K`{{}} searches page bodies, `-k`{{}} searches
the one-line descriptions, and that single letter is the whole difference.

</details>
