#!/usr/bin/env python3
"""Every command a step tells you to run has to exist on the box.

The gap this closes: the drill's steps were converted to use `answer N`, but
that scenario's background.sh had never installed the helper, because the old
version had no use for one. Nothing failed. Step 1 would simply have said
"answer: command not found" on Killercoda, and the first person to find out
would have been the learner.

Two checks:

1. A helper any scenario creates under /usr/local/bin is a scenario helper. If a
   scenario's steps use one, that scenario's own background.sh must create it.
   This is exact and needs no box.
2. Everything else a step asks you to run must be a real command here. Absent
   ones are skipped by name, because a package this box lacks is not a scenario
   bug; CI installs them all and runs with --no-skips, where a skip is a
   failure.

  python3 tests/test_commands.py             skip what is not installed
  python3 tests/test_commands.py --no-skips  a skip is a failure (CI)
"""
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
# Fenced blocks carrying a Killercoda action are the ones a learner runs.
RUNNABLE = re.compile(r"```\n([^`]*?)```\{\{(?:exec|copy)[^}]*\}\}", re.S)
HELPER = re.compile(r"/usr/local/bin/([A-Za-z0-9._-]+)")

# Shell built-ins and syntax that are not commands to look up.
IGNORE = {
    "if", "then", "else", "elif", "fi", "for", "do", "done", "while", "case",
    "esac", "exit", "cd", "echo", "export", "set", "unset", "source", ".",
    "true", "false", "EOF", "JSON", "UNIT", "}", "{", "#", "|", "&&", "fi;",
    "type", "command", "local", "return", "read", "shift", "printf",
}

errors, skipped = [], []
scenarios = sorted(p.parent for p in ROOT.glob("*/index.json"))

# Every helper any scenario installs, so a step using one is recognisable.
all_helpers = set()
for d in scenarios:
    bg = d / "background.sh"
    if bg.is_file():
        all_helpers |= set(HELPER.findall(bg.read_text(encoding="utf-8")))

checked = 0
for d in scenarios:
    bg = d / "background.sh"
    mine = set(HELPER.findall(bg.read_text(encoding="utf-8"))) if bg.is_file() else set()

    used = set()
    for md in sorted(d.glob("*.md")):
        for block in RUNNABLE.findall(md.read_text(encoding="utf-8")):
            # A block of configuration rather than commands: nginx, JSON, a
            # unit file. Its keywords are not commands and never were.
            if re.search(r"[{]\s*$|^\s*[}]\s*$", block, re.M):
                continue
            heredoc = None
            for line in block.splitlines():
                # Text fed to a command is data, not more commands.
                if heredoc is not None:
                    if line.strip() == heredoc:
                        heredoc = None
                    continue
                m = re.search(r"<<-?\s*'?([A-Za-z_][A-Za-z0-9_]*)'?", line)
                if m:
                    heredoc = m.group(1)
                line = line.strip()
                if not line or line.startswith(("#", ">", "<", "-")):
                    continue
                # First word of the first command in the line.
                word = re.split(r"[\s|;&]+", line)[0]
                word = word.lstrip("$(").strip("\"'`")
                # A command name, not a config key, a section header or prose.
                if not re.fullmatch(r"[a-z][a-z0-9._+-]*", word):
                    continue
                if word in IGNORE:
                    continue
                used.add(word)

    for cmd in sorted(used):
        checked += 1
        if cmd in mine:
            continue
        if cmd in all_helpers:
            errors.append(f"{d.name}: steps run '{cmd}', which is a helper this "
                          f"scenario's background.sh does not install")
            continue
        found = shutil.which(cmd) or shutil.which(cmd, path="/usr/sbin:/sbin")
        if found is None:
            skipped.append(f"{d.name}: '{cmd}' is not installed here")

print(f"  {len(scenarios)} scenario(s), {checked} command reference(s) checked")
for s in skipped:
    print(f"  skip  {s}")

if "--no-skips" in sys.argv and skipped:
    errors.append(f"{len(skipped)} command(s) skipped with --no-skips: a step "
                  "asks the learner to run something that is not on this box")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every command a step asks for exists")
