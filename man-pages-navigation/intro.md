# Find it in the man pages

In the LFCS exam you get man pages, `/usr/share/doc`, and the packages installed
on the box. Nothing else. No browser, no notes, no search engine.

So the thing worth drilling is not what you remember. It is **how fast you can
find what you don't remember** — which section holds it, which one-line search
gets you there, and which pager key stops you scrolling through nine screens of
`mount(8)` looking for one option.

Six lookups. Each one has a single correct answer that you can only get by
opening a page. Record each with the `answer` command:

```
answer 1 5
```{{copy}}

Then press **Check** to verify.

> The base image ships without man pages. They are installing now — give it a
> minute before you start, and `man -k quota` will tell you when it is ready.
