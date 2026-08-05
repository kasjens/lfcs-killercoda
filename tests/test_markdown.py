#!/usr/bin/env python3
"""Guard against markdown Killercoda's renderer mishandles.

Killercoda makes every inline code span copyable by injecting a copy button
after it. Sometimes that injection lands after the opening backtick instead of
the closing one, markdown escapes it, and the learner reads the markup:

    So <span class='kc-markdown-code-copy'></span>man git clone fails

Two live sightings, in man-pages-drill and in essential-commands. The trigger
was never pinned down: the renderer is server side, and the two paragraphs have
no pattern in common that the paragraphs rendering correctly do not also have.
An earlier guess -- two code spans separated only by a full stop and a space --
passed on the second sighting, which is how it came back.

So the injection is turned off instead. Killercoda documents `code`{{}} as the
way to do that, and nothing is lost: this deck never asks anyone to click
inline code, and every command to run sits in a fenced block with {{exec}} or
{{copy}}. No injection, no markup to leak.

Both checks below exist to keep that true. A code span split across a source
line break is rejected too, because the marker has to sit against the closing
backtick and a rewrap is what pulls it away.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CODE = re.compile(r"`[^`\n]+`(\{\{[^}]*\}\})?")

errors, checked, spans = [], 0, 0

for md in sorted(ROOT.glob("*/*.md")):
    checked += 1
    fenced = False
    for n, line in enumerate(md.read_text(encoding="utf-8").split("\n"), 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        where = f"{md.relative_to(ROOT)}:{n}"
        if line.count("`") % 2:
            errors.append(f"{where}: code span split across lines — {line.strip()}")
        for m in CODE.finditer(line):
            spans += 1
            if not m.group(1):
                errors.append(f"{where}: inline code without a marker — "
                              f"{m.group(0)} should be {m.group(0)}{{{{}}}}")

# Every step offers a way forward when stuck and a way to check afterwards.
# A step with neither is a dead end for anyone who cannot get it.
for step in sorted(ROOT.glob("*/step*.md")):
    body = step.read_text(encoding="utf-8")
    if "<summary>Tip" not in body:
        errors.append(f"{step.relative_to(ROOT)}: no Tip block")
    if "<summary>Solution</summary>" not in body:
        errors.append(f"{step.relative_to(ROOT)}: no Solution block")

print(f"  {checked} markdown file(s) checked, {spans} inline code span(s)")
print(f"  {len(list(ROOT.glob('*/step*.md')))} step(s) checked for tips and solutions")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every inline code span opts out of the copy button")
