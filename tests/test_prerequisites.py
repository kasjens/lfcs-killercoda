#!/usr/bin/env python3
"""Whatever a task's setup puts on the box, the scenario must put there too.

Each task in questions.json carries a `setup` that recreates what background.sh
would have left on the box before the learner starts. Nothing checked that the
two agreed, so a step could ask for work on something only the test harness
ever created. That shipped twice:

  - networking step 7 said dummy1 and dummy2 were already present. They were
    not, and every command in the step answered "Cannot find device".
  - essential-commands step 4 asked for a drop-in constraining hello.service,
    and the unit did not exist, so `systemctl cat hello.service` showed nothing.

Both passed CI, because the harness created them itself and then verified its
own work.

So: everything a setup creates has to be accounted for, by background.sh, by an
earlier step's solution (state the learner built and carries forward), or by an
entry in the scenario's `provided_by_install` list, which is for paths that
come from a package the scenario installs and names the package.

/tmp is skipped. Paths under it in a setup are the harness's own bookkeeping --
where it stashed a loop device name, a listener's pid -- not scenario state.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = json.loads((ROOT / "tests" / "questions.json").read_text(encoding="utf-8"))

IFACE = re.compile(r"\bip (?:link|netns) add (\S+)")
MKDIR = re.compile(r"\bmkdir -p ([^|;&\n]+)")
WRITE = re.compile(r">>?\s*(/[A-Za-z0-9._/-]+)")

errors, checked = [], 0


def artifacts(commands):
    """Names and paths a setup brings into existence."""
    found = []
    for cmd in commands:
        found += IFACE.findall(cmd)
        for hit in MKDIR.findall(cmd):
            found += [w for w in hit.split() if w.startswith("/")]
        found += WRITE.findall(cmd)
    return [a for a in dict.fromkeys(found) if not a.startswith("/tmp/")]


for name, scenario in MANIFEST["scenarios"].items():
    tasks = scenario.get("tasks", [])
    if not tasks:
        continue
    background = (ROOT / name / "background.sh")
    provided = background.read_text(encoding="utf-8") if background.is_file() else ""
    # A map of path -> what puts it there, so the exception says why it is one.
    allowed = set(scenario.get("provided_by_install", {}))

    for task in tasks:
        # State an earlier step built is the learner's own and carries forward.
        earlier = " ".join(c for t in tasks if t["n"] < task["n"]
                           for c in t.get("solve", []))
        for item in artifacts(task.get("setup", [])):
            checked += 1
            if item in allowed:
                continue
            # A path may sit somewhere else on the box than in the sandbox, so
            # the file's own name is enough to show the scenario creates it.
            base = item.rsplit("/", 1)[-1]
            if item in provided or (base and base in provided):
                continue
            if item in earlier or (base and base in earlier):
                continue
            errors.append(
                f"{name} step {task['n']} ({task['title']}): setup creates "
                f"{item}, but {name}/background.sh does not, no earlier step "
                f"does, and it is not in provided_by_install")

print(f"  {checked} task prerequisite(s) traced to the scenario that creates them")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every task setup matches what the box is given")
