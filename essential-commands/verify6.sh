#!/bin/bash
# Step 6: SSL. Reads the certificate with openssl rather than trusting the
# filename, so a copied file with the wrong subject does not pass.
bad=0
note() { echo "$1" >&2; bad=1; }
crt=/etc/ssl/certs/lfcs.crt
key=/etc/ssl/private/lfcs.key

[ -f "$crt" ] || { echo "$crt does not exist yet" >&2; exit 1; }
[ -f "$key" ] || note "$key does not exist"

subject="$(openssl x509 -in "$crt" -noout -subject 2>/dev/null)"
if [ -z "$subject" ]; then
  note "$crt is not a certificate openssl can read"
else
  printf '%s' "$subject" | grep -q 'lfcs.example.com' \
    || note "the certificate subject is ${subject#subject=}, without CN=lfcs.example.com"
fi

# Still valid, and valid for a good while, which is what -days bought.
if ! openssl x509 -in "$crt" -noout -checkend 0 >/dev/null 2>&1; then
  note "the certificate has already expired"
elif openssl x509 -in "$crt" -noout -checkend 25920000 >/dev/null 2>&1; then
  : # more than 300 days left, fine
else
  note "the certificate expires in under 300 days, so it was not issued for a year"
fi

# The key has to belong to the certificate. Comparing the public key of each is
# the check that catches a key generated separately and never used.
if [ -f "$key" ]; then
  a="$(openssl x509 -in "$crt" -noout -pubkey 2>/dev/null)"
  b="$(openssl pkey -in "$key" -pubout 2>/dev/null)"
  if [ -z "$b" ]; then
    note "$key is not a private key openssl can read"
  elif [ "$a" != "$b" ]; then
    note "$key is not the key this certificate was issued for"
  fi
  perms="$(stat -c %a "$key" 2>/dev/null)"
  case "$perms" in
    600|640|400|440) ;;
    *) note "$key is mode $perms, which is too open for a private key" ;;
  esac
fi

exit "$bad"
