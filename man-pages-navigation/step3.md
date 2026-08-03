# Inside a long page

`mount(8)` is about nine screens. Scrolling it is how people lose four minutes.

man renders through `less`, so every `less` key works:

| Key | Does |
|---|---|
| `/word` | search forward — headings are UPPERCASE, so search in caps to land on the heading |
| `n` / `N` | next / previous match |
| `g` / `G` | top / end |
| `&word` | **show only the lines that match** — everything else is hidden |
| `h` | the full key list, offline, allowed in the exam |
| `q` | quit |

`&` is the one almost nobody knows and the one that pays. On a page like
`mount(8)` or `nfs(5)` it turns two minutes of scrolling into one line of typing.

### Task

Two options out of `mount(8)`, and one key out of the pager itself.

**7.** The mount option that **prevents binaries being executed** from the
mounted filesystem.

**8.** The mount option that **stops set-user-ID and set-group-ID bits taking
effect** on it.

**9.** The pager key that jumps straight to the **end** of a page. Case matters:
the other case does the opposite.

Read 7 and 8 out of the page. Both are in the same list, so `&` earns its keep
here:

```
man 8 mount
```{{exec}}

Record the options as they would appear in `/etc/fstab`, and the key as the
single character you press:

```
answer 7 <option>
answer 8 <option>
answer 9 <key>
```{{copy}}

<details><summary>Tip</summary>

Inside the page, type `&exec` and press Enter. Every line mentioning exec, and
nothing else. Press `&` then Enter with an empty pattern to switch it off. For
question 8, `&suid` narrows it the same way.

Question 9 is in the pager's own help, which is `h` from inside any page, or
`man less` from outside it.

</details>

<details><summary>Solution</summary>

```
answer 7 noexec
answer 8 nosuid
answer 9 G
```{{copy}}

Both options are in the filesystem-independent list in `mount(8)`. The key `G`
goes to the end and `g` to the top, which is why the question said case matters.

</details>
