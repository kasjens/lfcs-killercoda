# Monitor and troubleshoot system performance

Three tools cover most of what the exam asks, and they come from two different
packages, which matters when one of them is missing from a fresh box.

Virtual memory statistics, meaning memory, swap, I/O and CPU sampled over an
interval, come from a tool in `procps`. Its page is in **section 8**, not 1,
which surprises people who expect a reporting tool to be a user command. Per
device I/O statistics and historical activity reports both come from `sysstat`,
and those two pages are in section 1.

The distinction worth carrying: a tool that samples the machine live and a tool
that reports what a collector already recorded are different jobs. The second
only has data if its collector has been running, which is why it can be
installed and still tell you nothing.

### Task

**9.** The command that reports virtual memory statistics.

**10.** The section that command's page lives in. It is not the one you would
guess.

**11.** The command that reports per-device I/O statistics.

**12.** The command that reports system activity collected over time.

```
answer 9 <command>
answer 10 <number>
answer 11 <command>
answer 12 <command>
```{{copy}}

<details><summary>Tip</summary>

`man -k` searches one-line descriptions, which is exactly where these three
describe themselves:

```
man -k 'statistics'
man -k 'system activity'
```{{exec}}

`whatis` gives you the section number for question 10 without opening anything.

</details>
