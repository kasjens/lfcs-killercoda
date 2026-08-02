#!/usr/bin/env python3
"""
lfcs man page drill — production format, run in a real terminal.

The React version made you type into a text box. Here the same 50 items sit
next to a live Ubuntu box with real man pages, so every answer you are unsure
of can be settled in the next pane rather than guessed.

  drill                     a round of 15 from every topic
  drill -n 25               longer round
  drill -t sections         one topic (sections, discovery, pager, beyond, exam)
  drill --review            only the items you did not produce cold last round
  drill --list              show the topics and item counts

At the prompt:  ?      reveals the answer
                !      after a miss, counts it anyway
                :quit  ends the round early

(":quit" rather than "q" — one of the pager items has "q" as its answer.)
"""

import argparse
import json
import os
import random
import re
import sys
import time
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
BANK = os.environ.get("LFCS_DRILL_BANK", os.path.join(HERE, "bank.json"))
STATE_DIR = os.environ.get("LFCS_DRILL_STATE", "/tmp/lfcs-drill")
HISTORY = os.path.join(STATE_DIR, "history.json")

# Control tokens must never be a legitimate answer. "q" and ":q" both are —
# they are how you leave the pager — so quitting is spelled out in full.
# tests/test_bank.py asserts these stay collision-free as the bank grows.
CONTROL_SHOW = "?"
CONTROL_COUNT = "!"
CONTROL_QUIT = ":quit"

LIVES = 5
XP_CORRECT = 25
XP_STREAK_BONUS = 10
STREAK_AT = 3

# ---------------------------------------------------------------- rendering

USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def c(code, s):
    return f"\033[{code}m{s}\033[0m" if USE_COLOR else s


AMBER = lambda s: c("38;5;179", s)   # noqa: E731  man page bold
CYAN = lambda s: c("38;5;80", s)     # noqa: E731  man page underline
GREEN = lambda s: c("38;5;72", s)    # noqa: E731
RED = lambda s: c("38;5;167", s)     # noqa: E731
DIM = lambda s: c("2", s)            # noqa: E731
BOLD = lambda s: c("1", s)           # noqa: E731

TOPIC_COLOR = {
    "SECTIONS": AMBER,
    "DISCOVERY": CYAN,
    "PAGER": lambda s: c("38;5;175", s),
    "BEYOND": GREEN,
    "EXAM": lambda s: c("38;5;140", s),
}


def width():
    try:
        return min(os.get_terminal_size().columns, 78)
    except OSError:
        return 78


def rule(left, center):
    """The header line every man page opens with."""
    w = width()
    pad = w - len(left) * 2 - len(center)
    if pad < 2:
        pad = 2
    lspace = pad // 2
    rspace = pad - lspace
    return AMBER(left) + " " * lspace + DIM(center) + " " * rspace + AMBER(left)


def head(text):
    print("\n" + AMBER(BOLD(text)))


def body(text, indent=7):
    w = width() - indent
    words, line = text.split(), ""
    for word in words:
        if len(line) + len(word) + 1 > w:
            print(" " * indent + line)
            line = word
        else:
            line = f"{line} {word}".strip()
    if line:
        print(" " * indent + line)


# ---------------------------------------------------------------- matching
# Identical rules to the React build, so a correct answer there is correct here.

SMART = str.maketrans({"\u2018": "'", "\u2019": "'", "\u201c": "'", "\u201d": "'"})


def norm(s, case_sensitive):
    v = (s or "").translate(SMART)
    v = re.sub(r"^\s*sudo\s+", "", v)
    v = re.sub(r"\s+", " ", v)
    v = re.sub(r"[.,;:]+$", "", v)
    v = v.strip()
    return v if case_sensitive else v.lower()


def hit(given, blank):
    """True if `given` is an accepted form of this blank's answer."""
    cs = bool(blank.get("cs"))
    v = norm(given, cs)
    if not v:
        return False
    pool = [norm(p, cs) for p in [blank["answer"]] + blank.get("accept", [])]
    if v in pool:
        return True
    bare = lambda t: t.replace('"', "").replace("'", "")  # noqa: E731
    return bare(v) in [bare(p) for p in pool]


# ---------------------------------------------------------------- state


def load_bank():
    try:
        with open(BANK, encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        sys.exit(f"question bank not found at {BANK}")


def read_history():
    try:
        with open(HISTORY, encoding="utf-8") as fh:
            return json.load(fh)
    except (FileNotFoundError, ValueError):
        return []


def write_history(entry):
    os.makedirs(STATE_DIR, exist_ok=True)
    rounds = read_history()
    rounds.append(entry)
    with open(HISTORY, "w", encoding="utf-8") as fh:
        json.dump(rounds, fh, indent=2)


# ---------------------------------------------------------------- the round


def ask(q, topics):
    """Run one item. Returns 'cold' | 'revealed' | 'missed' | 'quit'."""
    label = topics[q["topic"]]["label"]
    sec = topics[q["topic"]]["sec"]
    paint = TOPIC_COLOR.get(q["topic"], AMBER)

    print()
    print(rule(f"{label}({sec})", ""))
    head("NAME")
    body(paint(q["name"]))
    head("TASK")
    body(q["task"])
    print()

    revealed = False
    given = []
    for i, blank in enumerate(q["blanks"]):
        if len(q["blanks"]) > 1:
            print(DIM("       " + blank.get("label", f"part {i + 1}").upper()))
        try:
            raw = input("       " + paint("$ "))
        except (EOFError, KeyboardInterrupt):
            print()
            return "quit"
        if raw.strip() == CONTROL_QUIT:
            return "quit"
        if raw.strip() == CONTROL_SHOW:
            revealed = True
            given = [b["answer"] for b in q["blanks"]]
            break
        given.append(raw)

    if revealed:
        print()
        for blank in q["blanks"]:
            print("       " + AMBER("\u25c7 " + blank["answer"]))
        outcome = "revealed"
    else:
        results = [hit(given[i], b) for i, b in enumerate(q["blanks"])]
        print()
        for i, blank in enumerate(q["blanks"]):
            if results[i]:
                print("       " + GREEN("\u2713 " + given[i].strip()))
            else:
                print("       " + RED("\u2717 " + given[i].strip()))
                print("       " + GREEN("\u2192 " + blank["answer"]))
        outcome = "cold" if all(results) else "missed"

    head("WHY")
    body(q["explain"])
    head("LOCK IT IN")
    body(paint(q["mnemonic"]))

    if outcome == "missed":
        print()
        try:
            again = input(DIM("       press Enter, or " + CONTROL_COUNT
                          + " if that was only wording: "))
        except (EOFError, KeyboardInterrupt):
            print()
            return "quit"
        if again.strip() == CONTROL_COUNT:
            outcome = "cold"
    return outcome


def run(bank, chosen, args):
    topics = bank["topics"]
    lives, xp, streak, best = LIVES, 0, 0, 0
    history = []
    started = time.time()

    print()
    print(rule("MAN-DRILL(1)", "LFCS lookup drill"))
    print()
    body(f"{len(chosen)} items. {LIVES} lives. "
         f"{CONTROL_SHOW} reveals, {CONTROL_QUIT} ends the round.", indent=7)
    body("The terminal beside this one has real man pages. Use it to settle", indent=7)
    body("anything you are unsure of — that is the skill being drilled.", indent=7)

    for n, q in enumerate(chosen, 1):
        outcome = ask(q, topics)
        if outcome == "quit":
            print(DIM("\n       round ended early\n"))
            break
        history.append({"id": q["id"], "topic": q["topic"], "kind": outcome})
        if outcome == "cold":
            streak += 1
            best = max(best, streak)
            gain = XP_CORRECT + (XP_STREAK_BONUS if streak >= STREAK_AT else 0)
            xp += gain
            print("\n" + GREEN(f"       +{gain} XP") + DIM(f"   streak {streak}"))
        else:
            streak = 0
            if outcome == "missed":
                lives -= 1
        # filled vs hollow, not colour, so lives are legible with NO_COLOR set
        hearts = "\u2665" * max(lives, 0) + DIM("\u2661" * (LIVES - max(lives, 0)))
        print(DIM(f"\n       {n}/{len(chosen)}   ") + hearts + DIM(f"   {xp} XP"))
        if lives <= 0:
            print(RED("\n       out of lives\n"))
            break

    summary(history, topics, xp, best, len(chosen), time.time() - started, args)


def summary(history, topics, xp, best, planned, elapsed, args):
    total = len(history)
    if total == 0:
        return
    cold = sum(1 for h in history if h["kind"] == "cold")
    revealed = sum(1 for h in history if h["kind"] == "revealed")
    missed = sum(1 for h in history if h["kind"] == "missed")
    pct = round(cold * 100 / total)

    print()
    print(rule("MAN-DRILL(1)", "round complete"))
    head("RESULT")
    tone = GREEN if pct >= 70 else AMBER
    print(f"       {tone(BOLD(str(pct) + '%'))} produced cold")
    print()
    print(f"       {GREEN(str(cold)):>16}  produced cold")
    print(f"       {AMBER(str(revealed)):>16}  needed the reveal")
    print(f"       {RED(str(missed)):>16}  missed")
    print()
    print(DIM(f"       {total} of {planned} attempted   {xp} XP   "
              f"best streak {best}   {int(elapsed)}s"))
    print()
    body("A reveal is not a miss, but it is not knowledge either. The first "
         "number is the one that will still be true in September.")

    head("BY TOPIC")
    per = {}
    for h in history:
        slot = per.setdefault(h["topic"], [0, 0])
        slot[1] += 1
        if h["kind"] == "cold":
            slot[0] += 1
    for topic, (good, n) in sorted(per.items(), key=lambda kv: kv[1][0] / kv[1][1]):
        share = round(good * 100 / n)
        bar = "\u2588" * round(share / 5) + DIM("\u2591" * (20 - round(share / 5)))
        weak = RED("  weak") if share < 70 else ""
        paint = TOPIC_COLOR.get(topic, AMBER)
        print(f"       {paint(topics[topic]['label']):<22} {bar} {good}/{n}{weak}")

    not_cold = [h["id"] for h in history if h["kind"] != "cold"]
    if not_cold:
        head("NEXT")
        body(f"{len(not_cold)} items were not produced cold. Repeat only those:")
        print("\n       " + AMBER("drill --review"))

    write_history({
        "finished": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "topic": args.topic or "ALL",
        # A review round is otherwise indistinguishable from a short normal
        # one, which left verify3.sh guessing from the item count.
        "review": bool(args.review),
        "asked": total,
        "planned": planned,
        "cold": cold,
        "revealed": revealed,
        "missed": missed,
        "pct": pct,
        "xp": xp,
        "seconds": int(elapsed),
        "notCold": not_cold,
    })
    print()


# ---------------------------------------------------------------- entry


def main():
    bank = load_bank()
    topics = bank["topics"]
    keys = {k.lower(): k for k in topics}

    ap = argparse.ArgumentParser(
        prog="drill", description="LFCS man page lookup drill",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"at the prompt:  {CONTROL_SHOW} reveals   "
               f"{CONTROL_COUNT} counts a wording miss   {CONTROL_QUIT} quits")
    ap.add_argument("-n", "--count", type=int, default=15, help="items in the round")
    ap.add_argument("-t", "--topic", help=f"one of: {', '.join(sorted(keys))}")
    ap.add_argument("--review", action="store_true",
                    help="only the items not produced cold last round")
    ap.add_argument("--list", action="store_true", help="topics and item counts")
    ap.add_argument("--seed", type=int, help="fixed shuffle, for a repeatable round")
    args = ap.parse_args()

    if args.list:
        print()
        for key, meta in topics.items():
            n = sum(1 for q in bank["questions"] if q["topic"] == key)
            print(f"  {TOPIC_COLOR.get(key, AMBER)(meta['label']):<24} {n:>3} items"
                  f"   {DIM('drill -t ' + key.lower())}")
        print(f"\n  {'TOTAL':<15} {len(bank['questions']):>3} items\n")
        return

    pool = bank["questions"]

    if args.review:
        rounds = read_history()
        if not rounds:
            sys.exit("no previous round to review. Run `drill` first.")
        wanted = set(rounds[-1].get("notCold", []))
        if not wanted:
            print(GREEN("\n  Last round was clean — nothing to review.\n"))
            return
        pool = [q for q in pool if q["id"] in wanted]
        args.count = len(pool)
    elif args.topic:
        key = keys.get(args.topic.lower())
        if not key:
            sys.exit(f"unknown topic '{args.topic}'. Try: {', '.join(sorted(keys))}")
        pool = [q for q in pool if q["topic"] == key]

    rng = random.Random(args.seed)
    chosen = pool[:] if args.review else rng.sample(pool, min(args.count, len(pool)))
    run(bank, chosen, args)


if __name__ == "__main__":
    main()
