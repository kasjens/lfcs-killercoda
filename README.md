# lfcs-killercoda

Killercoda scenarios covering every domain of the current LFCS syllabus, plus
two that drill the skill the rest assume: finding things in the man pages fast
enough that it does not cost you the task.

**Prep.** Lookups, to build the reflex.

| Scenario | What it is |
|---|---|
| [`man-pages-navigation`](man-pages-navigation) | Six steps, fifteen verified lookups. Every answer requires opening a page. |
| [`man-pages-drill`](man-pages-drill) | Six steps, fifty-six typed answers on sections, search, the pager and LFCS lookups. |

**Domains.** Performance based, like the exam: you change the box and the check
reads the machine.

| Scenario | Weight | Steps |
|---|---|---|
| [`essential-commands`](essential-commands) | 20% | 6 |
| [`users-and-groups`](users-and-groups) | 10% | 4 tasks + 1 lookup |
| [`storage`](storage) | 20% | 7 |
| [`networking`](networking) | 25% | 8 |
| [`operations`](operations) | 25% | 6 tasks + 2 lookups |

The syllabus is the five-domain one effective 11 May 2023. Most third-party
study guides still publish the older six-domain split, which weights networking
at 12% where the real exam weights it 25%.

Once the repo is connected to a Killercoda profile they appear at:

```
https://killercoda.com/<profile>/scenario/<directory name>
```

A competency that cannot honestly be performed on a single box is a lookup step
and says so: LDAP needs a directory server, libvirt needs nested
virtualisation, and SELinux is not what Ubuntu enforces.

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
├── background.sh       installs man pages and the `answer` helper
├── step1.md … step6.md
├── verify1.sh … verify6.sh    generated from tests/questions.json
└── finish.md

<domain>/               one directory per LFCS domain, same shape
├── index.json
├── background.sh       installs the tooling and plants any faults to find
├── step1.md …          theory, then the task
└── verify1.sh …        read system state, not a typed answer

tests/
├── questions.json          every lookup question and every task's solution
├── validate_scenarios.py   every file index.json references must exist
├── test_questions.py       lookup answers checked against the real pages
├── test_tasks.py           each task verifier fails before, passes after
└── test_verifiers.sh       verifiers accept right answers, reject wrong ones

tools/
└── gen_verifiers.py        writes the lookup verifiers from questions.json
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
python3 tests/test_questions.py
python3 tests/test_tasks.py
bash tests/test_verifiers.sh
find . -name '*.sh' -exec shellcheck -s bash -e SC2148 {} +
```

`test_questions.py` checks every lookup answer against the page it claims:
that the page exists, in the section claimed, and that its rendered text really
contains the term. `test_tasks.py` runs each task verifier against a clean box,
requires it to **fail**, applies the reference solution, and requires it to
**pass** — the failure that matters is a verifier that passes before the
learner has done anything.

Root for that comes from a user namespace, so it runs unprivileged and never
touches the real `/etc`. Two Storage tasks need loop devices, which no
namespace can provide; they skip locally and run as root on CI.

CI runs all of them on every push, with skips treated as failures.

Two of them need more than a checkout. `test_verifiers.sh` stages a unit file
under `/etc/systemd/system`, so step 6 only runs as root, and step 5 needs
`nfs(5)` installed. Both announce a skip rather than failing. A skip is not a
pass, so CI installs the man pages first and fails outright if either check
would have skipped.

## Accuracy

Section numbers were checked against the man page paths the packages actually
ship, by extracting the `.deb` files, rather than written from memory. Three
that commonly get written down wrong:

- `chage` is section **1**, not 8 — an unprivileged user can run `chage -l`.
- `WorkingDirectory=` is in `systemd.exec(5)`, not `systemd.service(5)`.
- The `OnCalendar=` grammar is in `systemd.time(7)`, not `systemd.timer(5)`.
- `vmstat` is section **8**; `iostat` and `sar` are section 1.
- `man ulimit` gives you the C function in section 3, not the shell builtin.

Every lookup answer in the domain scenarios is re-checked against the installed
page on each CI run, so a section that moves between package versions fails the
build rather than quietly teaching the wrong thing.

## Grouping them into a course

Killercoda treats a shared subdirectory as a course. Moving the domain folders
into one directory would group them into an ordered path. They are at the top
level here so each gets its own URL and none depends on `structure.json` being
right: a wrong `structure.json` hides every scenario outside it, which is a bad
failure mode to discover close to an exam.
