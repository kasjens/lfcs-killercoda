# Manage virtual machines with libvirt

This competency cannot be performed here. Running a guest needs nested
virtualisation, which this backend does not offer, and a scenario that had you
type `virsh` commands against nothing would teach you that they succeed when
they would not. So this step is lookups, against pages that really are
installed on this box.

libvirt separates three things, and the naming follows.

**The daemon** does the work and owns the state. It has a section 8 page,
because it is a system service you do not invoke directly.

**The client** is how you talk to it. It has a section 1 page, because it is a
command you run, and it is one command with dozens of subcommands: `list`,
`start`, `shutdown`, `dumpxml`, `edit`, `define`. Running it with no arguments
drops you into an interactive shell, which surprises people once.

**The domain XML** is the guest definition. `dumpxml` prints it, `edit` opens
it, and `define` registers a guest from it. "Domain" here means a guest, which
collides with every other meaning of the word in this exam.

The distinction that matters under time pressure: `shutdown` asks the guest to
stop and needs a cooperating guest agent, while `destroy` cuts the power. The
word is aggressive but the operation is ordinary, and confusing the two costs
you either time or data.

### Task

Three lookups. Record each with the `answer` command, then press **Check**.

**1.** The command-line client for managing libvirt guests.

**2.** The section that client's page lives in.

**3.** The libvirt daemon itself.

```
answer 1 <command>
answer 2 <number>
answer 3 <daemon>
```{{copy}}

<details><summary>Tip</summary>

```
man -k libvirt
whatis virsh
```{{exec}}

The client and the daemon differ by more than a suffix, and their section
numbers tell you which is which without opening either.

</details>
