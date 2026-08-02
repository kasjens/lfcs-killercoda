#!/usr/bin/env python3
"""Checks on the question bank and the drill's matching rules."""
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "man-pages-drill" / "assets"

spec = importlib.util.spec_from_file_location("drill", ASSETS / "drill.py")
drill = importlib.util.module_from_spec(spec)
spec.loader.exec_module(drill)

bank = json.loads((ASSETS / "bank.json").read_text())
questions, topics = bank["questions"], bank["topics"]
errors = []

seen = set()
for q in questions:
    if q["id"] in seen:
        errors.append(f"duplicate id {q['id']}")
    seen.add(q["id"])
    if q["topic"] not in topics:
        errors.append(f"{q['id']}: unknown topic {q['topic']}")
    for field in ("name", "task", "explain", "mnemonic"):
        if not q.get(field):
            errors.append(f"{q['id']}: missing {field}")
    if not q.get("blanks"):
        errors.append(f"{q['id']}: no blanks")
        continue

    for i, b in enumerate(q["blanks"]):
        # An answer must satisfy its own matcher.
        if not drill.hit(b["answer"], b):
            errors.append(f"{q['id']}.{i}: answer {b['answer']!r} fails its matcher")
        for a in b.get("accept", []):
            if not drill.hit(a, b):
                errors.append(f"{q['id']}.{i}: accept {a!r} fails the matcher")

    # In a multi-blank item, one blank's answer must not satisfy another.
    if len(q["blanks"]) > 1:
        if any("label" not in b for b in q["blanks"]):
            errors.append(f"{q['id']}: multi-blank item without labels")
        for i, a in enumerate(q["blanks"]):
            for j, b in enumerate(q["blanks"]):
                if i != j and drill.hit(a["answer"], b):
                    errors.append(f"{q['id']}: blank {i} also satisfies blank {j}")

# The reason this file exists: ":quit" replaced "q" because "q" is the real
# answer to the pager item. Any control token that is also an answer makes that
# item unanswerable.
forms = {f.strip().lower()
         for q in questions for b in q["blanks"]
         for f in [b["answer"], *b.get("accept", [])]}
for token in (drill.CONTROL_SHOW, drill.CONTROL_COUNT, drill.CONTROL_QUIT):
    if token.lower() in forms:
        errors.append(f"control token {token!r} collides with a real answer")

# Case-sensitive items must stay case-sensitive: -k and -K differ only by case.
for q in questions:
    for b in q["blanks"]:
        if b.get("cs") and drill.hit(b["answer"].swapcase(), b):
            errors.append(f"{q['id']}: marked case-sensitive but matches swapped case")

print(f"  {len(questions)} questions, "
      f"{sum(len(q['blanks']) for q in questions)} blanks, "
      f"{len(topics)} topics")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  bank consistent, control tokens collision-free")
