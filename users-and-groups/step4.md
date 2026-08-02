# Configure and manage ACLs

Classic Unix permissions describe exactly three subjects: the owner, one group,
and everyone else. ACLs exist because that is not enough when two different
groups need two different levels of access to the same file.

An ACL adds named entries: this user gets read and write, that group gets read.
`ls -l` shows a `+` after the permission bits when a file carries one, which is
the only hint you get that the mode string is not the whole story.

The mask is the part that surprises people. It is not a permission, it is a
ceiling. Every named user entry, every named group entry, and the owning group
entry are filtered through it, so an entry granting `rwx` under a mask of `r--`
grants `r--` in practice. `getfacl` prints an `#effective:` comment when a
mask is reducing an entry, which is your clue that the ACL is not doing what it
appears to say. Changing the group bits with `chmod` rewrites the mask, which
is how ACLs silently stop working after an unrelated permission change.

Directories can also carry a default ACL, which is not enforced on the
directory itself. It is the template that new files inside it inherit.

Two commands, one for reading and one for writing, both in section 1 because
any user can inspect and change the ACLs on their own files. The model itself
gets its own page in section 5.

### Task

**13.** The command that displays a file's ACL.

**14.** The command that sets an ACL.

**15.** The page describing the ACL model itself. Page name, no section number.

**16.** The ACL entry type that caps effective permissions.

```
answer 13 <command>
answer 14 <command>
answer 15 <page name>
answer 16 <entry type>
```{{copy}}

<details><summary>Tip</summary>

```
man -k acl
man 5 acl
```{{exec}}

Question 15 is not one of the two commands. It is the page that explains
entries, defaults and the ceiling, and `man -k acl` shows it with a different
section number from the other two.

</details>
