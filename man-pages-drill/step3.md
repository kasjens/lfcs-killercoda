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

<details><summary>Prefer it scored and shuffled?</summary>

The drill program is still installed. It picks items at random, keeps score
with lives and a streak, and `drill --review` repeats only what you did not
produce cold. It does not feed this step's check, so use it as extra practice
rather than instead.

```
drill -t discovery -n 8
```{{copy}}

</details>
