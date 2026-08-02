#!/bin/bash
# setquota sets limits from the command line; edquota opens an editor.
a="$(tr -d '[:space:]' < /tmp/answers/2 2>/dev/null | tr '[:upper:]' '[:lower:]')"
[ "$a" = "setquota" ]
