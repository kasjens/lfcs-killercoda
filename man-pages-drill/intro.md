# Man page speed drill

Fifty items across five topics. You **type the command** — there are no options
to choose from, because the exam does not offer any either.

The terminal beside this text has real man pages on it. That is the whole point.
When an item catches you out, do not just read the explanation: open the page and
look. Being wrong and then finding the answer in eleven seconds is exactly the
loop the exam rewards.

| Topic | Items | About |
|---|---|---|
| SECTIONS | 16 | which numbered page holds a thing |
| DISCOVERY | 10 | `-k`, `-K`, `apropos`, `whatis`, `mandb` |
| PAGER | 8 | searching and filtering inside a page |
| BEYOND-MAN | 8 | `/usr/share/doc`, `dpkg -L`, `rpm -qd`, `systemctl cat` |
| EXAM-LOOKUPS | 8 | LFCS-shaped tasks — where would you look |

Five lives. 25 XP an item, plus 10 at a three streak. At the prompt:

| Type | Does |
|---|---|
| `?` | reveal the answer — no life lost, no XP, counted separately |
| `!` | after a miss, if it was only wording, count it |
| `:quit` | end the round |

The score that matters is **produced cold** — the reveals are tracked apart from
it on purpose. A reveal is not a miss, but it is not knowledge either.

> Section numbers in this drill were checked against the man page paths that the
> packages actually ship, not written from memory.
