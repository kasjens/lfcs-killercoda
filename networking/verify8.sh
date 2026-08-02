#!/bin/bash
# Step 8: reverse proxy. Reads the site configuration, and lets nginx judge it
# where the binary is available.
bad=0
note() { echo "$1" >&2; bad=1; }

site=""
for f in /etc/nginx/sites-available/lfcs /etc/nginx/conf.d/lfcs.conf; do
  [ -f "$f" ] && site="$f"
done
[ -n "$site" ] || { echo "no lfcs site under /etc/nginx/sites-available or conf.d" >&2; exit 1; }

conf="$(cat "$site")"

printf '%s\n' "$conf" | grep -qE 'listen[[:space:]]+8080' \
  || note "the site does not listen on 8080"

printf '%s\n' "$conf" | grep -qE 'proxy_pass[[:space:]]+http://127\.0\.0\.1:3000' \
  || note "there is no proxy_pass to http://127.0.0.1:3000"

# Without this the backend sees nginx's own Host header and generates wrong
# absolute URLs, which is the classic reverse proxy bug.
printf '%s\n' "$conf" | grep -qiE 'proxy_set_header[[:space:]]+Host' \
  || note "the Host header is not forwarded, so the backend sees the wrong hostname"

# Without this every request appears to come from the proxy itself.
printf '%s\n' "$conf" | grep -qiE 'proxy_set_header[[:space:]]+X-Forwarded-For' \
  || note "X-Forwarded-For is not set, so the backend cannot see the client address"

# Enabled, not merely written. A file in sites-available does nothing.
if [ -d /etc/nginx/sites-enabled ] && [ "$site" = "/etc/nginx/sites-available/lfcs" ]; then
  find /etc/nginx/sites-enabled -name lfcs 2>/dev/null | grep -q . \
    || note "the site is in sites-available but not enabled in sites-enabled"
fi

if command -v nginx >/dev/null 2>&1; then
  nginx -t >/dev/null 2>&1 || note "nginx rejects the configuration"
fi

exit "$bad"
