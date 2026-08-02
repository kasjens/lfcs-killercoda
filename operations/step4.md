# Search for, install, validate and maintain software packages

Three files decide what apt will install and from where.

**The source.** A line in `/etc/apt/sources.list.d/*.list`, or the newer
deb822 `.sources` format. The shape is `deb [options] URI suite component`.

**The key.** apt refuses an unsigned repository, and the correct fix is telling
it which key signs this one, not disabling the check. `signed-by=` names a
keyring file and scopes that key to this repository only. The old advice,
`apt-key add`, is deprecated precisely because it trusted a key for
*everything*, so one compromised third-party repo could sign a replacement for
any package on the system.

**The pin.** Priorities in `/etc/apt/preferences.d/` decide which candidate
wins when a package exists in more than one place. The numbers are not
arbitrary:

| Priority | Effect |
|---|---|
| `< 0` | never install |
| `100` | installed packages only |
| `500` | the normal default |
| `990` | the target release |
| `> 1000` | **install even if it means downgrading** |

That last row is the one worth remembering. Anything above 1000 will
downgrade, which is how you force a specific version from a specific origin.

`apt-cache policy <pkg>` shows every candidate with its priority and is the
command that tells you why apt picked what it picked.

### Task

Add a third-party repository and hold nginx to it:

1. `/etc/apt/sources.list.d/lfcs.list` pointing at **`https://repo.example.com`**,
   suite **stable**, component **main**, with **`signed-by=`** naming
   `/etc/apt/keyrings/lfcs.gpg`.
2. `/etc/apt/preferences.d/lfcs` pinning **nginx** to that origin at priority
   **1001**.

Do not run `apt update`: the repository does not exist.

<details><summary>Tip</summary>

```
man 5 sources.list
man 5 apt_preferences
```{{exec}}

`apt_preferences(5)` has the priority table and worked examples of the three
lines a pin needs: `Package:`, `Pin:` and `Pin-Priority:`.

</details>

<details><summary>Solution</summary>

```
printf 'deb [signed-by=/etc/apt/keyrings/lfcs.gpg] https://repo.example.com stable main\n' > /etc/apt/sources.list.d/lfcs.list
printf 'Package: nginx\nPin: origin repo.example.com\nPin-Priority: 1001\n' > /etc/apt/preferences.d/lfcs
```{{copy}}

</details>
