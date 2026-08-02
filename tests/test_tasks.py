#!/usr/bin/env python3
"""Prove every task verifier fails before the task and passes after it.

The domain scenarios ask the learner to change the box, so their verifiers read
system state rather than a typed answer. The failure that matters is a verifier
that passes before anything has been done, which looks like a working scenario
and teaches nothing. Testing for it needs the task actually performed, which
needs root.

So each task carries a reference solution and this runs the cycle:

    clean state -> verify MUST fail -> run the solution -> verify MUST pass

Root comes from a user namespace rather than sudo, so it works unprivileged
here and identically on CI, and the real /etc is never touched. Inside the
namespace /etc, /home and /srv are replaced with writable copies. Anything
needing real root, block devices or a live systemd is marked sandbox "root" and
skipped where that is not available.

  python3 tests/test_tasks.py             skip what cannot run here
  python3 tests/test_tasks.py --no-skips  a skip is a failure (CI)
"""
import json
import os
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = json.loads((ROOT / "tests" / "questions.json").read_text(encoding="utf-8"))
errors, skipped, ran = [], [], 0

# The scenario dir lives under /home, which the sandbox masks, so the verifier
# is copied somewhere that survives. /tmp explicitly: TMPDIR may point at /home.
SANDBOX = r"""
set -e
E=$(TMPDIR=/tmp mktemp -d); cp -a /etc/. "$E"/ 2>/dev/null || true
: > "$E"/shadow; : > "$E"/gshadow; chmod 640 "$E"/shadow "$E"/gshadow
mount --bind "$E" /etc
mount -t tmpfs tmpfs /home
mount --bind {srv} /srv
set +e
"""


# --map-auto matters when unprivileged: plain -r maps only uid 0, so chgrp and
# setfacl to any other id fail with EINVAL and an ACL task looks broken when it
# is not. It needs a subuid/subgid range for the calling user. Real root has
# every id already and may have no subuid range at all, so it does not use it.
UNSHARE = ["unshare", "-rm"] + ([] if os.geteuid() == 0 else ["--map-auto"])


def userns_problem() -> str:
    """Empty string if the sandbox works, otherwise why it does not."""
    p = subprocess.run(UNSHARE + ["true"], capture_output=True, text=True)
    if p.returncode == 0:
        return ""
    reason = p.stderr.strip().splitlines()[-1:] or ["unshare failed"]
    if "--map-auto" in UNSHARE:
        return f"{reason[0]} (unprivileged sandbox needs a subuid range; try running as root)"
    return reason[0]


def run_cycle(verifier: Path, solve: str, srv: Path) -> tuple[str, str]:
    """Return (before, after) as 'pass' | 'fail' | 'error'."""
    with tempfile.TemporaryDirectory(dir="/tmp") as work:
        script = Path(work) / "verify.sh"
        script.write_text(verifier.read_text(encoding="utf-8"), encoding="utf-8")
        body = SANDBOX.format(srv=shlex.quote(str(srv))) + f"""
bash {shlex.quote(str(script))} >/dev/null 2>&1; echo "before=$?"
{solve}
bash {shlex.quote(str(script))} >/dev/null 2>&1; echo "after=$?"
"""
        p = subprocess.run(UNSHARE + ["sh", "-c", body],
                           capture_output=True, text=True, timeout=180)
        codes = {}
        for line in p.stdout.splitlines():
            if "=" in line and line.split("=")[0] in ("before", "after"):
                k, v = line.split("=", 1)
                codes[k] = v.strip()

        def state(key: str) -> str:
            code = codes.get(key)
            if code is None:
                return "error"
            # 127 is "script not found", which would otherwise read as a
            # correct failure and hide a broken harness.
            if code == "127":
                return "error"
            return "pass" if code == "0" else "fail"

        return state("before"), state("after")


userns_error = userns_problem()

for name, scenario in MANIFEST["scenarios"].items():
    for task in scenario.get("tasks", []):
        step = task["n"]
        verifier = ROOT / name / f"verify{step}.sh"
        if not verifier.is_file():
            errors.append(f"{name} step {step}: {verifier.name} does not exist")
            continue
        if task.get("sandbox") == "root" or userns_error:
            why = "needs real root" if task.get("sandbox") == "root" else userns_error
            skipped.append(f"{name} step {step} ({task['title']}): {why}")
            continue

        with tempfile.TemporaryDirectory(dir="/tmp") as srv:
            before, after = run_cycle(verifier, "\n".join(task["solve"]), Path(srv))
        ran += 1
        if before == "error" or after == "error":
            errors.append(f"{name} step {step}: the verifier could not be run in the sandbox")
            continue
        if before != "fail":
            errors.append(f"{name} step {step} ({task['title']}): "
                          "verifier passes before the task is done")
        if after != "pass":
            errors.append(f"{name} step {step} ({task['title']}): "
                          "verifier still fails after the reference solution")

print(f"  {ran} task verifier(s) exercised before and after their solution")
for s in skipped:
    print(f"  skip  {s}")

if "--no-skips" in sys.argv and skipped:
    errors.append(f"{len(skipped)} task(s) skipped with --no-skips")

if errors:
    print("\nFAILED", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("  every task fails before it is done and passes after")
