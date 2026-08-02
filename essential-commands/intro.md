# Essential commands

The Essential Commands domain is 20% of the LFCS exam. Despite the name it is
not "basic Linux". Since the May 2023 revision it means six specific things:
Git, services, performance, resource constraints, disk space, and SSL
certificates.

One step per competency. Each step opens with the theory, then asks a set of
questions you answer from the man pages on the box beside you.

Twenty-four questions, numbered straight through. Record each with the `answer`
command:

```
answer 1 git clone
```{{copy}}

That writes to `/tmp/answers/1`, which is the file the check reads, so plain
redirection does the same job:

```
echo git clone > /tmp/answers/1
```{{copy}}

Answer the whole set, then press **Check**. A wrong answer names the question it
belongs to, so you can go back to just that one.

> The base image ships without man pages. They are installing now, and the
> terminal will say when they are live.
