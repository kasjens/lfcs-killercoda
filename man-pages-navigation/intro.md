# Find it in the man pages

In the LFCS exam you get man pages, `/usr/share/doc`, and the packages installed
on the box. Nothing else. No browser, no notes, no search engine.

So the thing worth drilling is not what you remember. It is **how fast you can
find what you don't remember** — which section holds it, which one-line search
gets you there, and which pager key stops you scrolling through nine screens of
`mount(8)` looking for one option.

Six steps, fifteen lookups. Each one has a single correct answer that you can
only get by opening a page. The questions are numbered straight through, and a
step passes when every question in its set is right.

Record each answer with the `answer` command:

```
answer 1 5
```{{copy}}

That writes `5` to `/tmp/answers/1`, which is the file the check reads. Nothing
more to it, so redirection does the same job if you prefer:

```
echo 5 > /tmp/answers/1
```{{copy}}

Answer the whole set, then press **Check**. A wrong answer names the question it
belongs to, so you can go back to just that one.

> The base image ships without man pages. They are installing now — give it a
> minute before you start, and `man -k quota` will tell you when it is ready.
