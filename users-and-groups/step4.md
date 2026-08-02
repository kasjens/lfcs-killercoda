# Configure and manage ACLs

Classic Unix permissions describe exactly three subjects: the owner, one group,
and everyone else. ACLs exist because that is not enough when one extra person
needs access to a directory that already belongs to a group.

`ls -l` shows a `+` after the permission bits when a file carries an ACL, which
is the only hint that the mode string is not the whole story.

Three things in the model catch people out.

**The mask is a ceiling, not a permission.** Every named user entry, every named
group entry and the owning group entry is filtered through it. An entry granting
`rwx` under a mask of `r--` grants `r--` in practice, and `getfacl` prints an
`#effective:` comment when that is happening. Running `chmod` on the group bits
rewrites the mask, which is how ACLs silently stop working after an unrelated
change.

**Default entries are a template, not a rule.** A default ACL on a directory is
not enforced on the directory. It is what new files inside it inherit. Set the
access entry and forget the default, and everything created tomorrow is
inaccessible.

**ACLs do not set the group of new files.** That is the setgid bit on the
directory. The two are solving different halves of the same problem and shared
directories usually need both.

### Task

Set up a shared directory at **`/srv/webops`**:

1. Group **`webops`**, with the **setgid** bit so new files keep that group.
2. An ACL entry giving user **`deploy`** **rwx** on the directory.
3. A **default** ACL so files created inside it inherit `deploy` rwx.
4. The mask must not reduce `deploy` below `rwx`.

If `deploy` and `webops` do not exist yet, create them.

<details><summary>Tip</summary>

```
man 1 setfacl
man 5 acl
```{{exec}}

`setfacl` uses one flag to mean "this is a default entry". Find it in the page
rather than guessing, then confirm with `getfacl /srv/webops`: default entries
are printed with a `default:` prefix.

The setgid bit is not an ACL at all. It is a mode bit, so it comes from `chmod`.

</details>

<details><summary>Solution</summary>

```
groupadd -g 4000 webops
useradd -M -g webops deploy
mkdir -p /srv/webops
chgrp webops /srv/webops
chmod 2770 /srv/webops
setfacl -m u:deploy:rwx /srv/webops
setfacl -d -m u:deploy:rwx /srv/webops
```{{copy}}

</details>
