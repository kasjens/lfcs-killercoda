# Basic Git operations

Git ships one man page per subcommand, named with a hyphen: `git-clone(1)`, not
`git clone(1)`. So `man git clone` fails and `man git-clone` works. That naming
is the only thing standing between you and every Git answer in the exam.
`git help <verb>` opens the same page.

Two things about a first commit catch people out.

Git refuses to commit without an identity, and the error it gives is long
enough that people paste it into a search engine instead of reading it. You can
set the identity globally or per repository, and per repository is what you
want on a shared box.

Staging is a separate step from committing. `git add` moves a change into the
index, `git commit` records what is in the index. A file you edited but never
added is not in the commit, and `git status` will keep telling you so.

A branch is just a name pointing at a commit, which is why you cannot create
one in an empty repository. There is no commit for it to point at yet.

### Task

Build a repository at **`/srv/app`**:

1. Initialise it as a Git repository.
2. Set `user.name` and `user.email` **in that repository's own config**, not
   globally.
3. Create a `README.md`, and commit it. Leave nothing uncommitted.
4. Create a branch called **`release`**.

<details><summary>Tip</summary>

```
man git-init
man git-config
man git-branch
```{{exec}}

`git-config(1)` explains the difference between `--global` and `--local` and
which file each one writes. `git status` after committing should report a clean
tree.

</details>

<details><summary>Solution</summary>

```
git init -q /srv/app
cd /srv/app
git config user.name 'LFCS Candidate'
git config user.email 'candidate@example.com'
echo '# app' > README.md
git add README.md
git commit -q -m 'Add README'
git branch release
```{{copy}}

</details>
