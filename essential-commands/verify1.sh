#!/bin/bash
# Step 1: Git. Reads the repository, so any route to the right history passes.
bad=0
note() { echo "$1" >&2; bad=1; }
repo=/srv/app

[ -d "$repo/.git" ] || { echo "$repo is not a git repository yet" >&2; exit 1; }

g() { git -C "$repo" "$@" 2>/dev/null; }

# Identity has to be set or the commit could not have been made at all, but
# check it explicitly so an inherited global config is not mistaken for work.
name="$(g config --local user.name)"
mail="$(g config --local user.email)"
[ -n "$name" ] || note "user.name is not set in this repository's own config"
[ -n "$mail" ] || note "user.email is not set in this repository's own config"

count="$(g rev-list --count HEAD)"
case "$count" in
  ''|0) note "the repository has no commits" ;;
esac

g log --oneline -- README.md | grep -q . \
  || note "no commit touches README.md"

# A branch, not a tag and not a detached head.
if ! g show-ref --verify --quiet refs/heads/release; then
  note "there is no release branch"
fi

# Nothing left uncommitted, which is what makes the commit real rather than staged.
if [ -n "$(g status --porcelain)" ]; then
  note "the working tree has uncommitted changes"
fi

exit "$bad"
