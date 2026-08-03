# Man page speed drill

Fifty-six typed answers on the lookups that come up most: section numbers,
searching when you have forgotten a command name, pager keys, documentation
outside the man pages, and the handful of LFCS pages that are not where you
would guess.

Six steps, grouped by topic. Every answer is typed, never picked from a list,
because the exam does not offer a list either. Record each one with the
`answer` command:

```
answer 1 man 5 fstab
```{{copy}}

That writes to `/tmp/answers/1`, which is the file the check reads, so plain
redirection does the same job:

```
echo 'man 5 fstab' > /tmp/answers/1
```{{copy}}

Answer a step's set, then press **Check**. A wrong answer names the question it
belongs to, so you can go back to just that one.

The terminal beside this one has real man pages. Anything you are unsure of can
be settled there in ten seconds, and doing that is the skill being drilled.
