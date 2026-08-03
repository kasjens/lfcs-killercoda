# PAGER

Everything man shows you goes through `less`, so pager keys are the fastest
speed-up available. Filtering a nine-screen page down to the six lines that
matter is worth more in an exam than remembering any single flag.

### Task

10 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**28.** *get to the examples*

You are inside a long man page. Type exactly what you press to jump to the
EXAMPLES heading.

**29.** *repeat the search*

The first hit was not the one you wanted. Type the key for the next match,
then the key for the previous match. (next match)

Case matters here.

**30.** *the second part of the same item* (previous match)

Case matters here.

**31.** *both ends of the page*

Type the key that jumps to the end of the page, then the key that jumps back
to the top. (end)

Case matters here.

**32.** *the second part of the same item* (top)

Case matters here.

**33.** *leave*

Type the key that closes the pager and returns you to the shell.

**34.** *hide everything else*

Inside mount(8) you want to see only the lines that mention noexec. Type
exactly what you press.

Case matters here.

**35.** *search backwards*

You scrolled past the option you wanted. Type exactly what you press to search
backwards for noexec.

Case matters here.

**36.** *the pager's own help*

You have forgotten a less key mid-page. Type the key that shows the full
command summary.

**37.** *half a screen*

Type the keystroke that scrolls down half a screen — finer than a full page
when you are skimming an option list.

```
answer 28 <your answer>
answer 29 <your answer>
answer 30 <your answer>
answer 31 <your answer>
answer 32 <your answer>
answer 33 <your answer>
answer 34 <your answer>
answer 35 <your answer>
answer 36 <your answer>
answer 37 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**28.** Headings shout. Search in caps to hit the heading, not the paragraph.

**29.** Shift reverses. Everywhere in less, and in vim too.

**30.** Shift reverses. Everywhere in less, and in vim too.

**31.** Big G goes to the big end.

**32.** Big G goes to the big end.

**33.** q for quit, and it is the same key in less, top and journalctl.

**34.** & is grep inside less. The one pager key most people never learn.

**35.** Forward slash leans forward. The question mark curls back.

**36.** h for help, and it is allowed in the exam because it is not the
internet.

**37.** d for down, u for up, and hold Ctrl for half.

</details>

<details><summary>Solution</summary>

```
answer 28 /EXAMPLES
answer 29 n
answer 30 N
answer 31 G
answer 32 g
answer 33 q
answer 34 &noexec
answer 35 ?noexec
answer 36 h
answer 37 Ctrl-d
```{{copy}}

**28.** man renders through less, so every less search works. Headings are
uppercase, so searching for the uppercase word lands on the heading rather
than on prose mentions of the word.

**29.** Lowercase n goes forward, uppercase N goes back. Same as vim, which is
worth leaning on since you are drilling both.

**30.** Lowercase n goes forward, uppercase N goes back. Same as vim, which is
worth leaning on since you are drilling both.

**31.** g and G in less, same as vim's gg and G. Jumping to the end is how you
check whether a page has an EXAMPLES or SEE ALSO section without scrolling
through it.

**32.** g and G in less, same as vim's gg and G. Jumping to the end is how you
check whether a page has an EXAMPLES or SEE ALSO section without scrolling
through it.

**33.** q quits. Worth being deliberate about because Ctrl+C does not close
less, and on the exam a stuck pager wastes seconds you are counting.

**34.** & filters the display to matching lines only — the rest are hidden,
not just skipped. On a page as long as mount(8) or nfs(5) this turns two
minutes of scrolling into one line of typing. Press & then Enter with an empty
pattern to switch it off.

**35.** / searches forward, ? searches backward. n and N then step through the
results in whichever direction you started.

**36.** h prints the complete less command list, inside the pager, offline.
The less man page itself says that if you forget every other command, remember
this one.

**37.** Ctrl-d is half a screen down, Ctrl-u is half a screen up, Space is a
full screen. Half-screen scrolling keeps a few lines of context on screen,
which matters when you are reading a table of mount options.

</details>
