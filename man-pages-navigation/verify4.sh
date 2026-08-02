#!/bin/bash
# systemd.exec(5), not systemd.service(5) — accept the common spellings.
a="$(tr -d '[:space:]' < /tmp/answers/4 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$a" in
  systemd.exec|systemd.exec\(5\)|systemd.exec.5|man5systemd.exec) exit 0 ;;
  *) exit 1 ;;
esac
