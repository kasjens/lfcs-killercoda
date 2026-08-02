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

Three commands, each described but not named. Find all three with man alone.

**4.** Set a disk quota limit for a user **from the command line, without
opening an editor**.

**5.** Build the index that `apropos` reads. This is the command you run when a
search returns nothing appropriate.

**6.** Print the list of directories man searches for pages.

```
answer 4 <command>
answer 5 <command>
answer 6 <command>
```{{copy}}

<details><summary>Tip</summary>

Several results mention quotas. Read the one-line descriptions and pick the one
that sets limits non-interactively. One of the others opens an editor instead.

```
man -k quota
```{{exec}}

Questions 5 and 6 are both man's own tooling, so search its own descriptions:

```
man -k manual
apropos -s 1,8 'manual page'
```{{exec}}

</details>
