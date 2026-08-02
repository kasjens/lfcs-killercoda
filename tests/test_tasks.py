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
# The /etc copy is made in a directory Python owns, not by mktemp inside the
# namespace. A directory created in here is never cleaned up: the namespace
# exits and takes the only reference with it, leaving a full copy of /etc in
# /tmp per task. That filled /tmp, and then `cp -a /etc/.` began failing and
# every verifier broke at once.
E={etc}
mkdir -p "$E"; cp -a /etc/. "$E"/ 2>/dev/null || true
: > "$E"/shadow; : > "$E"/gshadow; chmod 640 "$E"/shadow "$E"/gshadow
mount --bind "$E" /etc
mount -t tmpfs tmpfs /home
mount -t tmpfs tmpfs /root
mount -t tmpfs tmpfs /mnt
mount --bind {srv} /srv
set +e
"""


# Root wants a mount namespace and nothing else: it already owns every uid, and
# adding -r would put it in a user namespace mapping only uid 0, where chgrp and
# setfacl to any other id fail with EINVAL.
#
# Unprivileged, the user namespace is the only way to get root at all, and it
# needs --map-auto plus a subuid range for the same reason: without it only uid
# 0 exists and an ACL task looks broken when it is not.
#
# --propagation private so the bind mounts cannot escape into the host.
UNSHARE = (["unshare", "-m", "--propagation", "private"] if os.geteuid() == 0
           else ["unshare", "-rm", "--map-auto", "--propagation", "private"])


def userns_problem() -> str:
    """Empty string if the sandbox works, otherwise why it does not."""
    p = subprocess.run(UNSHARE + ["true"], capture_output=True, text=True)
    if p.returncode == 0:
        return ""
    reason = p.stderr.strip().splitlines()[-1:] or ["unshare failed"]
    if "--map-auto" in UNSHARE:
        return f"{reason[0]} (unprivileged sandbox needs a subuid range; try running as root)"
    return reason[0]


def run_cycle(verifier: Path, setup: str, solve: str, cleanup: str,
              srv: Path, netns: bool = False) -> tuple[str, str, str]:
    """Return (before, after) as 'pass' | 'fail' | 'error'.

    `setup` recreates whatever the scenario's background.sh would have put on
    the box before the learner starts, so "before" is the state they actually
    meet rather than an empty machine.
    """
    with tempfile.TemporaryDirectory(dir="/tmp") as work:
        script = Path(work) / "verify.sh"
        script.write_text(verifier.read_text(encoding="utf-8"), encoding="utf-8")
        etcdir = shlex.quote(str(Path(work) / "etc"))
        body = SANDBOX.format(srv=shlex.quote(str(srv)), etc=etcdir) + f"""
{setup}
bash {shlex.quote(str(script))} >/dev/null 2>&1; echo "before=$?"
{solve}
AFTERLOG=$(TMPDIR=/tmp mktemp)
bash {shlex.quote(str(script))} > "$AFTERLOG" 2>&1; echo "after=$?"
# Pass the verifier's own complaint through. "still fails after the reference
# solution" without it means reading the source to find out why.
echo "---after-output---"; cat "$AFTERLOG"; echo "---end-after-output---"
rm -f "$AFTERLOG"
# Loop devices and volume groups are kernel-wide, so they outlive the mount
# namespace and would leak into the next task. Always runs, pass or fail.
{cleanup}

# Teardown has to happen in here. Everything these tasks create is written as
# root in the namespace, which is a subuid outside it, and the user running the
# tests cannot delete files owned by that subuid. Left alone, each run strands a
# full copy of /etc in /tmp; a few hundred of those exhausted the tmpfs inode
# table and then every verifier failed at once for no visible reason.
umount /etc 2>/dev/null
rm -rf {etcdir} 2>/dev/null
rm -rf /srv/..?* /srv/.[!.]* /srv/* 2>/dev/null
"""
        # A network task reconfigures interfaces, routes and firewall rules. In
        # its own network namespace that is free; without one it would take
        # down the connectivity of whatever is running the tests.
        cmd = UNSHARE + (["-n"] if netns else [])
        if netns:
            body = "ip link set lo up 2>/dev/null\n" + body

        # Output goes to a file, not a pipe. A task that backgrounds anything,
        # a listener for instance, leaves a child holding the inherited pipe,
        # and communicate() then waits for EOF long after the shell has exited.
        # That is a hang, not a failure, and it reads as one in CI.
        log = Path(work) / "out.txt"
        with log.open("w") as fh:
            subprocess.run(cmd + ["sh", "-c", body], stdin=subprocess.DEVNULL,
                           stdout=fh, stderr=fh, text=True, timeout=180)
        codes = {}
        for line in log.read_text(errors="replace").splitlines():
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

        text = log.read_text(errors="replace")
        detail = ""
        if "---after-output---" in text:
            detail = text.split("---after-output---", 1)[1] \
                         .split("---end-after-output---", 1)[0].strip()
        return state("before"), state("after"), detail


userns_error = userns_problem()

for name, scenario in MANIFEST["scenarios"].items():
    for task in scenario.get("tasks", []):
        step = task["n"]
        verifier = ROOT / name / f"verify{step}.sh"
        if not verifier.is_file():
            errors.append(f"{name} step {step}: {verifier.name} does not exist")
            continue
        # "root" means loop devices or device-mapper, which a user namespace
        # cannot provide however it is mapped. Those still run when we really
        # are root, which is how CI covers them; they only skip unprivileged.
        needs_root = task.get("sandbox") == "root"
        if (needs_root and os.geteuid() != 0) or userns_error:
            why = "needs real root for loop devices" if needs_root else userns_error
            skipped.append(f"{name} step {step} ({task['title']}): {why}")
            continue

        with tempfile.TemporaryDirectory(dir="/tmp") as srv:
            before, after, detail = run_cycle(verifier,
                                      "\n".join(task.get("setup", [])),
                                      "\n".join(task["solve"]),
                                      "\n".join(task.get("cleanup", [])),
                                      Path(srv),
                                      netns=task.get("sandbox") == "user-ns-net")
        ran += 1
        if before == "error" or after == "error":
            errors.append(f"{name} step {step}: the verifier could not be run in the sandbox")
            continue
        if before != "fail":
            errors.append(f"{name} step {step} ({task['title']}): "
                          "verifier passes before the task is done")
        if after != "pass":
            why = f": {detail.splitlines()[0]}" if detail else ""
            errors.append(f"{name} step {step} ({task['title']}): "
                          f"verifier still fails after the reference solution{why}")

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
