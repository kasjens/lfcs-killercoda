# Monitor storage performance

"The disk is slow" is a claim, and these tools are how you turn it into a
number.

`iostat`{{}} without arguments prints one report averaged **since boot**, which
is almost never what you want. Averaged over weeks, a disk that is saturated
right now looks fine. Give it an interval and a count, and the first report is
still the since-boot average while every report after it covers the interval.
So `iostat 1 2`{{}} and reading the **second** block is the actual measurement.

`-x`{{}} adds the extended columns, and they are the ones that answer the
question:

- **`%util`{{}}** is the share of time the device had at least one request in
  flight. On a spinning disk near 100% means saturated; on SSDs and NVMe it is
  misleading, because they service requests in parallel.
- **`await`{{}}** is the average time a request waited, in milliseconds,
  queueing plus service. Rising `await`{{}} with flat throughput means the
  queue is growing.
- **`aqu-sz`{{}}** is the average queue depth.

Throughput alone tells you nothing about health. A device doing 5 MB/s might be
idle or might be at its limit; `%util`{{}} and `await`{{}} are what separate
the two.

For per-process attribution rather than per-device, `pidstat -d`{{}} from the
same package breaks I/O down by process, which answers "which one of these is
doing it".

### Task

Capture a measurement to **`/root/iostat.txt`{{}}**:

1. **Extended** statistics.
2. At least **two reports** at a one-second interval, so the file contains a
   real sample and not only the since-boot average.

<details><summary>Tip</summary>

```
man 1 iostat
```{{exec}}

The interval and count are positional arguments, described near the top of the
page, the same shape as `vmstat`{{}}.

</details>

<details><summary>Solution</summary>

```
iostat -x 1 2 > /root/iostat.txt
```{{copy}}

</details>
