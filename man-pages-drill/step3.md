# DISCOVERY

When you cannot remember the name of a command, you search descriptions rather
than pages. `man -k` searches the one-line summaries and treats its argument
as a regular expression. `man -K` searches the body of every page, which is
slow but finds a directive nobody indexed.

### Task

10 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**18.** *you do not know the command name*

You need something to do with disk quotas but cannot remember any command
name. Type the command that searches page names and descriptions for quota.

**19.** *nothing appropriate*

man -k returns "nothing appropriate" on a freshly built minimal box. Type the
command that fixes it.

**20.** *the brute-force search*

You remember a directive called OnCalendar but not which page defines it. Type
the command that searches the full text of every man page.

Case matters here.

**21.** *what does this thing do*

Print the one-line description of ss without opening the page. Type the
command.

**22.** *narrow the search*

Search descriptions for mount but only inside section 5, so you get file
formats rather than a screen of commands. Type the command.

**23.** *too many hits*

apropos mount returns forty lines. Type the command that matches the keyword
exactly instead of on word boundaries.

**24.** *both words, not either*

You want pages whose description mentions both nfs and mount, not either one.
Type the command.

**25.** *where does the page live*

Print the path of the source file for the sshd_config page instead of
displaying it. Type the command.

**26.** *anchor the keyword*

man -k treats the keyword as a regular expression. Type the search that
matches only pages whose name starts with chage.

**27.** *where is man looking*

Print the list of directories man searches for pages. Type the command.

```
answer 18 <your answer>
answer 19 <your answer>
answer 20 <your answer>
answer 21 <your answer>
answer 22 <your answer>
answer 23 <your answer>
answer 24 <your answer>
answer 25 <your answer>
answer 26 <your answer>
answer 27 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**18.** -k for keyword. Do not know the name, know a word.

**19.** The db in mandb is the database that -k reads. No db, no keywords.

**20.** Little k, little search — just the descriptions. Big K, big search —
every word of every page.

**21.** whatis asks what it is. apropos asks what is about this.

**22.** -s for section, and it accepts a list: -s 5,8.

**23.** -e for exact.

**24.** -a for and. -e for exact. Both are narrowing tools.

**25.** -w for where.

**26.** It is a regex, so treat it like grep.

**27.** Like PATH, but for pages.

</details>

<details><summary>Solution</summary>

```
answer 18 man -k quota
answer 19 mandb
answer 20 man -K OnCalendar
answer 21 whatis ss
answer 22 apropos -s 5 mount
answer 23 apropos -e mount
answer 24 apropos -a nfs mount
answer 25 man -w sshd_config
answer 26 man -k '^chage'
answer 27 manpath
```{{copy}}

**18.** man -k is apropos: it searches the one-line NAME descriptions of every
page. It is the fastest way out of a blank on this exam, and it costs you
about three seconds.

**19.** apropos and whatis read a prebuilt index, not the pages themselves. On
a minimal install or a container that index does not exist yet. mandb builds
it. Learn this now rather than discovering it under the clock.

**20.** -K is global-apropos: it greps the body of every page, not just the
descriptions. It is slow enough to hurt, so narrow it with a section when you
can — man -K -s 5 OnCalendar. Capital K, and the difference from lowercase k
is not cosmetic.

**21.** whatis is man -f: exact name lookup, one line back. It also reveals
every section the name exists in, which is a quick way to spot a 1-and-5
collision before you open the wrong one.

**22.** -s takes a comma- or colon-separated section list and works on
apropos, whatis and man alike. Pair it with -K when a full-text search would
otherwise take a minute.

**23.** -e requires the keyword to match a whole page name or description
rather than appearing inside one. It is the difference between four results
and forty.

**24.** apropos defaults to OR across keywords. -a switches it to AND. Two
keywords with -a will usually get you to the right page in one shot where one
keyword gets you a wall.

**25.** -w prints the location rather than rendering. Handy when you want to
grep or zcat the raw page, or to confirm which of several installed copies you
are actually reading.

**26.** Because -k takes a regex, ^ and $ work. Anchoring turns a noisy search
into a precise one without needing -e.

**27.** manpath shows the resolved search path. If a page you just installed
is not being found, this is the first thing to check — and manpath(5)
documents the config file behind it.

</details>
