#!/bin/bash
# Step 4: ACLs. Reads the ACL off the directory, so any route to the right
# entries passes.
bad=0
note() { echo "$1" >&2; bad=1; }

dir=/srv/webops

if [ ! -d "$dir" ]; then
  echo "$dir does not exist yet" >&2
  exit 1
fi

acl="$(getfacl -p "$dir" 2>/dev/null)"
[ -n "$acl" ] || { echo "could not read an ACL from $dir"; exit 1; }

# The named entry: deploy needs rwx on the directory itself.
printf '%s\n' "$acl" | grep -qE '^user:deploy:rwx' \
  || note "no ACL entry giving deploy rwx on $dir"

# The mask has to allow it through, or the entry above is decorative.
mask="$(printf '%s\n' "$acl" | sed -n 's/^mask::\(.*\)$/\1/p' | tail -n1)"
if [ -n "$mask" ] && [ "$mask" != "rwx" ]; then
  note "the mask is $mask, so deploy's rwx is reduced to ${mask}"
fi

# Default entries are the template new files inherit. Without one, the ACL
# applies to what is there now and nothing created later.
printf '%s\n' "$acl" | grep -qE '^default:user:deploy:rwx' \
  || note "no default ACL entry, so new files under $dir will not inherit deploy's access"

# setgid keeps the group on new files, which is the half ACLs do not do.
perms="$(stat -c %a "$dir" 2>/dev/null)"
case "$perms" in
  2*) ;;
  "") note "could not stat $dir" ;;
  *) note "$dir is mode $perms, without the setgid bit new files will not stay in the group" ;;
esac

group="$(stat -c %G "$dir" 2>/dev/null)"
[ "$group" = "webops" ] || note "$dir belongs to group $group, not webops"

exit "$bad"
