#!/bin/bash
a="$(tr -d '[:space:]' < /tmp/answers/3 2>/dev/null | tr '[:upper:]' '[:lower:]')"
[ "$a" = "noexec" ]
