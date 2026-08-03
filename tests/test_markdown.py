#!/usr/bin/env python3
"""Guard against markdown Killercoda's renderer mishandles.

Killercoda injects a copy-button span into inline code. When two inline code
spans are separated only by a full stop and a space, that injection leaks into
the page as literal text, and the learner sees:

    not <span class='kc-markdown-code-copy'></span>fstab(5).

instead of the code. It was found on the live drill scenario, not here, so this
check exists to stop it coming back. Comma-separated pairs in the same position
have not been observed to break; only the full stop case is asserted, because
asserting more than was actually seen would mean rewriting prose on a guess.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FENCE = re.compile(r"```.*?```", re.S)
ADJACENT = re.compile(r"`[^`\n]+`\.\s+`[^`\n]+`")

errors, checked = [], 0

for md in sorted(ROOT.glob("*/*.md")):
    checked += 1
    text = FENCE.sub("", md.read_text(encoding="utf-8"))
    # Join wrapped lines so a pair split across two source lines is still seen.
    flat = re.sub(r"\n\s+", " ", text)
    for m in ADJACENT.finditer(flat):
        errors.append(f"{md.relative_to(ROOT)}: two inline code spans separated "
                      f"only by '. ' — {m.group(0)[:60]}")

print(f"  {checked} markdown file(s) checked for renderer-hostile patterns")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    print("  put a word between them, or reword", file=sys.stderr)
    sys.exit(1)
print("  no adjacent inline code spans")
