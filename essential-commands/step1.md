# Basic Git operations

Git ships one man page per subcommand, and the page is named with a hyphen:
`git-clone(1)`, not `git clone(1)`. So `man git clone` fails and `man git-clone`
works. That naming is the only thing standing between you and every Git answer
in the exam, because once you know it you can read any subcommand's page
without a browser.

`git help <verb>` opens the same page, which is worth remembering if the
hyphen slips your mind under time pressure.

The three operations below are the ones the domain names. A clone copies a
repository and its whole history into a new directory. A commit records what is
currently staged, which is why `git add` comes first and is a different verb.
The log walks the history that the commit wrote.

### Task

Four questions. Record all four, then press **Check**.

**1.** The command that copies an existing repository into a new directory.

**2.** The command that records staged changes into the history.

**3.** The command that shows the commit history.

**4.** The **man page name** for the clone subcommand, spelled as `man` wants
it.

```
answer 1 <command>
answer 2 <command>
answer 3 <command>
answer 4 <page name>
```{{copy}}

<details><summary>Tip</summary>

`man -k ^git-` lists every Git subcommand page at once, with the one-line
description that tells you which verb does what:

```
man -k '^git-' | head -30
```{{exec}}

Questions 1 to 3 want the command as you would type it, two words. Question 4
wants the page name, which is the same two words joined differently.

</details>
