# Work with SSL certificates

The certificate toolkit is one command with dozens of subcommands, and like Git
it documents each one on its own page. The naming follows the same shape:
`openssl-<subcommand>`. The subcommand that displays, converts and signs X.509
certificates is the one you will reach for most, because it is what reads a
certificate and tells you the subject, issuer and expiry.

These pages sit in a section of their own. The files land in `man1` but the
section is written `1ssl`, so `whatis openssl` reports something that looks
wrong and is not. That is a packaging convention to keep the toolkit's pages
from colliding with commands of the same name.

Trusting a certificate is a separate job from reading one. The system trust
store is a directory of certificates plus a bundle generated from it. Dropping
a CA certificate into the directory does nothing on its own: a command has to
rebuild the bundle. That command is administrative, so its page is in section
8.

### Task

**21.** The command suite for certificate operations.

**22.** The subcommand page for displaying and signing X.509 certificates.

**23.** The command that rebuilds the system trust store after you add a CA
certificate.

**24.** The section that command's page lives in.

```
answer 21 <command>
answer 22 <page name>
answer 23 <command>
answer 24 <number>
```{{copy}}

<details><summary>Tip</summary>

```
man -k openssl | head -20
man -k certificate
```{{exec}}

For question 22 the page name follows the same hyphenated pattern as Git. For
question 23, the description you are looking for mentions the certificate
directory rather than any one certificate.

</details>
