# Users and groups

The smallest domain at 10% of the exam, and the one where the answers are
spread across the most files. Five competencies: local accounts, environment
profiles, resource limits, ACLs, and LDAP lookups.

One step per competency. Each step opens with the theory, then asks a set of
questions you answer from the man pages on the box beside you.

Twenty questions, numbered straight through. Record each with the `answer`
command:

```
answer 1 useradd
```{{copy}}

That writes to `/tmp/answers/1`, which is the file the check reads, so plain
redirection does the same job:

```
echo useradd > /tmp/answers/1
```{{copy}}

Answer the whole set, then press **Check**. A wrong answer names the question it
belongs to, so you can go back to just that one.

> Do **LFCS prep 1: find it in the man pages** first if you have not. This
> scenario assumes `man -k`, `man -K`, `man -w` and the pager keys are already
> reflexes.
