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

Open `man 8 mount` and find the mount option that **prevents binaries being
executed** from the mounted filesystem.

```
man 8 mount
```{{exec}}

Then record it (just the option, as it would appear in `/etc/fstab`):

```
answer 3 <option>
```{{copy}}

<details><summary>Tip</summary>

Inside the page, type `&exec` and press Enter. Every line mentioning exec, and
nothing else. Press `&` then Enter with an empty pattern to switch it off.

</details>
