#!/bin/bash
# Step 2: environment profiles. Checks the effect, not the file: EDITOR has to
# actually arrive in a login shell, however you arranged it.
bad=0
note() { echo "$1" >&2; bad=1; }

# A login shell reads /etc/profile, which reads /etc/profile.d/*.sh. env -i
# clears the environment first so an EDITOR exported by hand does not pass.
got="$(env -i bash -lc 'printf %s "$EDITOR"' 2>/dev/null)"
if [ -z "$got" ]; then
  note "a fresh login shell has no EDITOR set"
elif [ "$got" != "vim" ]; then
  note "a login shell gets EDITOR=$got, not vim"
fi

# The default umask for new logins is a login.defs setting, not a shell one.
umask_line="$(grep -iE '^[[:space:]]*UMASK[[:space:]]+' /etc/login.defs 2>/dev/null | tail -n1)"
if [ -z "$umask_line" ]; then
  note "no UMASK line in /etc/login.defs"
else
  value="$(printf '%s' "$umask_line" | awk '{print $2}')"
  [ "$value" = "027" ] || note "login.defs sets UMASK $value, not 027"
fi

exit "$bad"
