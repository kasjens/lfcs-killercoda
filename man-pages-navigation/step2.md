# You forgot the command name

This is the situation that actually costs you time in the exam: you know what
you need to do, you cannot remember what the tool is called, and there is
nowhere to look it up.

`man -k` searches the name and one-line description of every page. `apropos` is
the same thing. It is a regular expression, so `^` and `$` work.

```
man -k quota
```{{exec}}

If that says **nothing appropriate**, the index has not been built. `apropos`
reads a database, not the pages themselves — `mandb` builds it. Worth knowing
before you meet it under the clock.

### Task

You need to set a disk quota limit for a user **from the command line, without
opening an editor**. Find that command using man only.

```
answer 2 <command>
```{{copy}}

<details><summary>Tip</summary>

Several results mention quotas. Read the one-line descriptions and pick the one
that sets limits non-interactively — one of the others opens an editor instead.

```
man -k quota
```{{exec}}

</details>
