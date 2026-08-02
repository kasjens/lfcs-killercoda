#!/usr/bin/env python3
"""Every file an index.json references must exist.

A scenario that points at a step file which is not there fails silently on
Killercoda — the step just renders blank. This is the check that catches it
before a push.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ALLOWED_TOP = {"title", "description", "details", "backend", "difficulty",
               "time", "tags", "icon", "index", "environment"}
ALLOWED_PHASE = {"title", "text", "verify", "foreground", "background"}

errors, checked = [], 0


def ref(scenario: Path, rel: str, field: str) -> None:
    global checked
    checked += 1
    if not (scenario / rel).is_file():
        errors.append(f"{scenario.name}: {field} -> missing file {rel!r}")


for index in sorted(ROOT.glob("*/index.json")):
    scenario = index.parent
    try:
        data = json.loads(index.read_text())
    except ValueError as exc:
        errors.append(f"{scenario.name}/index.json is not valid JSON: {exc}")
        continue

    for key in ("title", "description", "details", "backend"):
        if key not in data:
            errors.append(f"{scenario.name}: index.json has no {key!r}")
    for key in data:
        if key not in ALLOWED_TOP:
            errors.append(f"{scenario.name}: unexpected top-level key {key!r}")

    if "imageid" not in data.get("backend", {}):
        errors.append(f"{scenario.name}: backend has no imageid")

    details = data.get("details", {})

    for phase in ("intro", "finish"):
        block = details.get(phase)
        if not block:
            continue
        for key in block:
            if key not in ALLOWED_PHASE:
                errors.append(f"{scenario.name}: {phase} has unexpected key {key!r}")
        for key in ("text", "verify", "foreground", "background"):
            if key in block:
                ref(scenario, block[key], f"{phase}.{key}")

    steps = details.get("steps", [])
    if not steps:
        errors.append(f"{scenario.name}: no steps")
    for i, step in enumerate(steps, 1):
        for key in step:
            if key not in ALLOWED_PHASE:
                errors.append(f"{scenario.name}: step {i} unexpected key {key!r}")
        if "text" not in step:
            errors.append(f"{scenario.name}: step {i} has no text")
        for key in ("text", "verify", "foreground", "background"):
            if key in step:
                ref(scenario, step[key], f"step{i}.{key}")

    for host, items in details.get("assets", {}).items():
        for item in items:
            name = item.get("file", "")
            if any(ch in name for ch in "*?"):
                continue  # glob, resolved by Killercoda
            checked += 1
            if not (scenario / "assets" / name).is_file():
                errors.append(f"{scenario.name}: asset for {host} missing: "
                              f"assets/{name}")

    print(f"  {scenario.name}: {len(steps)} steps, ok")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print(f"\nall referenced files present ({checked} references checked)")
