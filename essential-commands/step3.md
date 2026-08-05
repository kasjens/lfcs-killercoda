# Monitor and troubleshoot system performance

There are two different jobs here and the tools split along that line.

**Sampling live** is what `vmstat`{{}} and `iostat`{{}} do. You give them an
interval and a count, and they report what is happening now. The first line of
`vmstat`{{}} output is an average since boot, not a sample, which is why
reading a single `vmstat`{{}} with no interval tells you almost nothing useful.

**Reporting history** is what `sar`{{}} does, and it can only report what a
collector already wrote down. That collector is a separate job installed with
the same package and, on Debian and Ubuntu, it ships **disabled**. So `sar`{{}}
can be installed, on your PATH, and still say it has no data. Turning it on is
a setting in `/etc/default/sysstat`{{}}.

A packaging detail worth carrying: `vmstat`{{}} is section **8** while
`iostat`{{}} and `sar`{{}} are section **1**, because they come from different
packages with different conventions. `whatis`{{}} settles it faster than
guessing.

### Task

1. Enable **sysstat data collection** so `sar`{{}} will have something to
   report.
2. Capture **three one-second samples** of virtual memory statistics to
   **`/root/vmstat.txt`{{}}**.

The check reads the file and counts sample rows, so a single snapshot will not
pass.

<details><summary>Tip</summary>

```
whatis vmstat iostat sar
man 8 vmstat
```{{exec}}

The `vmstat`{{}} page explains its two arguments in the first paragraph of
DESCRIPTION: one is the delay, the other is how many times to report.

For the collector, look at `/etc/default/sysstat`{{}}. It is a one-line change
and the file says what the setting does.

</details>

<details><summary>Solution</summary>

```
sed -i 's/^ENABLED=.*/ENABLED="true"/' /etc/default/sysstat
vmstat 1 3 > /root/vmstat.txt
```{{copy}}

</details>
