# EXAM-LOOKUPS

The lookups that come up most in LFCS itself: where a directive is documented,
which page owns a file format, and the handful of pages that are not where you
would guess.

### Task

10 answers. Record each one, then press **Check**. A wrong answer names the
question it belongs to, so you can go back to just that one.

**47.** *make it persist*

Task: set vm.swappiness to 10 and make it survive reboot. You have forgotten
whether the drop-in file needs a .conf suffix. One command.

**48.** *every Monday at 03:00*

Task: a timer that fires Mondays at 03:00. You have the unit sections but not
the OnCalendar grammar. Type the page.

**49.** *the bind mount*

Task: add a bind mount to /etc/fstab. bind is not described in fstab(5). Type
the page that documents it.

**50.** *default ACL*

Task: set a default ACL so new files inherit it. You have forgotten the flag.
Type the command to open the page, then what you press inside it to jump to
the right part. (open the page)

**51.** *the second part of the same item* (inside the page)

**52.** *rich rules*

Task: a firewalld rich rule that logs and rejects. Type the page with the rich
rule grammar.

**53.** *an nftables rule from scratch*

Task: add an nftables rule and you want a working example to copy. Type the
command, then what you press inside the page. (the page)

**54.** *the second part of the same item* (inside the page)

**55.** *journalctl since yesterday*

Task: show logs from the last two hours. You are unsure what --since accepts.
Type the page that defines the time expressions.

**56.** *nmcli, worked*

Task: create a static IPv4 connection with nmcli and you want copyable
examples rather than the flag reference. Type the command.

```
answer 47 <your answer>
answer 48 <your answer>
answer 49 <your answer>
answer 50 <your answer>
answer 51 <your answer>
answer 52 <your answer>
answer 53 <your answer>
answer 54 <your answer>
answer 55 <your answer>
answer 56 <your answer>
```{{copy}}

<details><summary>Tips</summary>

**47.** The command is 8, the drop-in directory is 5.

**48.** The directive is in the unit page. The grammar behind the directive is
in systemd.time(7).

**49.** fstab(5) gives you the columns. mount(8) gives you what goes in column
four.

**50.** Open, slash, read, q. Four moves, under fifteen seconds.

**51.** Open, slash, read, q. Four moves, under fifteen seconds.

**52.** One tool, many section 5 pages. When in doubt, man -k the product
name.

**53.** Long page, unfamiliar syntax: go to EXAMPLES first, not the top.

**54.** Long page, unfamiliar syntax: go to EXAMPLES first, not the top.

**55.** Anything systemd that smells like a date or a duration is
systemd.time(7).

**56.** man -k nmcli shows all three. The examples page is the one worth
opening first.

</details>

<details><summary>Solution</summary>

```
answer 47 man 5 sysctl.d
answer 48 man 7 systemd.time
answer 49 man 8 mount
answer 50 man setfacl
answer 51 /default
answer 52 man 5 firewalld.richlanguage
answer 53 man 8 nft
answer 54 /EXAMPLES
answer 55 man 7 systemd.time
answer 56 man 7 nmcli-examples
```{{copy}}

**47.** It does need .conf, and files are read in lexical order with /etc
winning over /usr/lib. All of that is on one page. Going to sysctl(8) instead
gives you the flags but not the file rules.

**48.** systemd.timer(5) tells you OnCalendar= exists. systemd.time(7) is
where the calendar grammar, the shorthands like weekly, and the timespan units
are actually defined — and it has worked examples you can copy. It is a 7
because it documents a syntax rather than a file.

**49.** fstab(5) describes the six columns but hands the fourth one — the
options — to mount(8). Every mount option you will ever need in fstab is
documented under FILESYSTEM-INDEPENDENT MOUNT OPTIONS in mount(8), and
filesystem-specific ones like the NFS set live in nfs(5).

**50.** It is -d. The pattern here matters more than the flag: open the page,
search rather than scroll, and get out. acl(5) covers the concept and the text
format if you need those instead.

**51.** It is -d. The pattern here matters more than the flag: open the page,
search rather than scroll, and get out. acl(5) covers the concept and the text
format if you need those instead.

**52.** firewalld splits across a dozen pages: firewall-cmd(1) for the tool,
firewalld.zone(5) for zone files, firewalld.richlanguage(5) for rich rules,
firewalld.conf(5) for the daemon. man -k firewalld lists them all in one line
if you cannot recall the suffix.

**53.** nft(8) is long, and its EXAMPLES section has complete table-chain-rule
blocks you can adapt. Searching straight to EXAMPLES is the single highest-
value pager habit for this exam — most admin pages have one.

**54.** nft(8) is long, and its EXAMPLES section has complete table-chain-rule
blocks you can adapt. Searching straight to EXAMPLES is the single highest-
value pager habit for this exam — most admin pages have one.

**55.** journalctl(1) says --since takes a timestamp and points at
systemd.time(7), which is where yesterday, -1h, and the absolute formats are
actually listed. Same page as the OnCalendar grammar, asked from the other
direction.

**56.** NetworkManager ships a separate examples page that almost nobody
finds. nmcli(1) is the flag reference, nm-settings-nmcli(5) is the property
list, and nmcli-examples(7) is the one with full working command lines for
static addressing, bonds and bridges.

</details>
