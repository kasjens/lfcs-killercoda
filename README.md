# lfcs-killercoda

Two Killercoda scenarios for the part of LFCS nobody drills: finding things in
the man pages fast enough that it does not cost you the task.

| Scenario | What it is |
|---|---|
| [`man-pages-navigation`](man-pages-navigation) | Six steps, fifteen verified lookups. Every answer requires opening a page. |
| [`man-pages-drill`](man-pages-drill) | Fifty scored items, typed answers, run as `drill` in the terminal. |

Once the repo is connected to a Killercoda profile they appear at:

```
https://killercoda.com/<profile>/scenario/man-pages-navigation
https://killercoda.com/<profile>/scenario/man-pages-drill
```

## Why a terminal and not a quiz

The exam gives you man pages, `/usr/share/doc`, and the installed packages.
Nothing else. So the skill is retrieval speed, and a multiple-choice box cannot
measure it — you can recognise `man 5 fstab` without being able to produce it,
and you can produce it without knowing that `bind` is documented in `mount(8)`
instead.

Killercoda gives a real Ubuntu VM, so every item the drill catches you on can be
settled in the same terminal ten seconds later. Being wrong and then finding the
answer quickly is the loop the exam actually rewards.

## Setup

1. Push this repo to GitHub.
2. On killercoda.com, go to your profile and add the repository.
3. Every push updates the scenarios, usually within a minute.

## Layout

```
man-pages-navigation/
├── index.json          scenario definition
├── intro.md            shown before the VM is ready
├── background.sh       installs man pages, runs mandb, adds the `answer` helper
├── foreground.sh       waits for background, reports whether man really works
├── step1.md … step6.md
├── verify1.sh … verify6.sh    run when the learner presses Check
└── finish.md

man-pages-drill/
├── index.json
├── assets/
│   ├── drill.py        the drill program
│   └── bank.json       50 items, 5 topics
├── background.sh       installs man pages + the drill, wires up /usr/local/bin/drill
├── step1.md … step3.md
├── verify1.sh … verify3.sh    read /tmp/lfcs-drill/history.json
└── finish.md

tests/
├── validate_scenarios.py   every file index.json references must exist
├── test_bank.py            bank consistency + control-token collisions
├── test_drill_round.py     a full round, answered correctly, scores 100%
└── test_verifiers.sh       verifiers accept right answers, reject wrong ones
```

## Two things the base image will do to you

**Ubuntu cloud and container images ship with documentation stripped.** A man
page scenario on an untouched image is a cruel joke. `background.sh` removes
`/etc/dpkg/dpkg.cfg.d/excludes`, installs `man-db manpages manpages-dev`,
reinstalls the packages whose pages the steps use, and runs `mandb`.

**On minimized images `/usr/bin/man` is a stub that exits 0.** It prints "This
system has been minimized" and returns success, so any check of the form
`man -w 5 nfs >/dev/null && ...` passes while doing nothing. `verify5.sh` and
the test harness therefore require the output to be an existing path beginning
with `/`, not merely a zero exit code.

## Running the tests locally

```bash
python3 tests/validate_scenarios.py
python3 tests/test_bank.py
python3 tests/test_drill_round.py
bash tests/test_verifiers.sh
find . -name '*.sh' -exec shellcheck -s bash -e SC2148 {} +
```

CI runs all five on every push. `test_drill_round.py` is the headless round: it
pipes the canonical answer to all 56 blanks and requires 100% cold.

Two of them need more than a checkout. `test_verifiers.sh` stages a unit file
under `/etc/systemd/system`, so step 6 only runs as root, and step 5 needs
`nfs(5)` installed. Both announce a skip rather than failing. A skip is not a
pass, so CI installs the man pages first and fails outright if either check
would have skipped.

## The drill

```
drill                     15 items across every topic
drill -n 50               all of them
drill -t pager            one topic
drill --review            only what you did not produce cold last round
drill --list              topics and counts
```

At the prompt: `?` reveals, `!` counts a wording-only miss, `:quit` ends the
round. It is `:quit` rather than `q` because `q` is the correct answer to one of
the pager items — `tests/test_bank.py` asserts the control tokens never collide
with a real answer.

Results land in `/tmp/lfcs-drill/history.json` and vanish with the session.

## Accuracy

Section numbers were checked against the man page paths the packages actually
ship, by extracting the `.deb` files, rather than written from memory. Three
that commonly get written down wrong:

- `chage` is section **1**, not 8 — an unprivileged user can run `chage -l`.
- `WorkingDirectory=` is in `systemd.exec(5)`, not `systemd.service(5)`.
- The `OnCalendar=` grammar is in `systemd.time(7)`, not `systemd.timer(5)`.

## Grouping them into a course

Killercoda treats a shared subdirectory as a course. Move both scenario folders
into one directory to group them — they are at the top level here so each gets
its own URL and neither depends on `structure.json` being right.
