#!/bin/bash
# Section 5 is file formats.
a="$(tr -d '[:space:]' < /tmp/answers/1 2>/dev/null)"
[ "$a" = "5" ]
