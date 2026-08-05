# Work with SSL certificates

The toolkit is one command with dozens of subcommands, and like Git it
documents each on its own page: `openssl-x509`{{}}, `openssl-req`{{}},
`openssl-genrsa`{{}}. These pages sit in a section written `1ssl`{{}}, so
`whatis openssl`{{}} reports something that looks wrong and is not. The files
still land in `man1`{{}}.

For generating a certificate the subcommand you want is the request one, not
the x509 one, which reads and converts existing certificates more often than it
makes them. It can do both, and the flag that makes it emit a self-signed
certificate instead of a signing request is the thing to find.

Three details the exam cares about.

**A subject on the command line avoids the interactive prompts.** Under time
pressure you do not want to answer six questions about your country. The flag
takes a slash-separated string, and the only field that usually matters is the
common name.

**A key with a passphrase cannot be used by a service that starts at boot,**
because nothing is there to type it. Generating without encryption is a
deliberate choice, not laziness, and there is a flag for it.

**A private key readable by anyone is not a private key.** Certificates are
public and live in a world-readable directory. Keys go somewhere restricted,
with restrictive permissions.

### Task

Generate a self-signed certificate:

1. Certificate at **`/etc/ssl/certs/lfcs.crt`{{}}**, key at
   **`/etc/ssl/private/lfcs.key`{{}}**.
2. Common name **`lfcs.example.com`{{}}**.
3. Valid for **365 days**.
4. The key must have **no passphrase**, and must not be readable by other
   users.

The check reads the certificate with `openssl`{{}}, confirms the key matches
it, and looks at the key's permissions.

<details><summary>Tip</summary>

```
man openssl-req
```{{exec}}

Look for the flags that: emit a self-signed certificate, create a new key at
the same time, skip encrypting that key, set the validity in days, and supply
the subject non-interactively. They are all on that one page.

Check your work:

```
openssl x509 -in /etc/ssl/certs/lfcs.crt -noout -subject -enddate
```{{exec}}

</details>

<details><summary>Solution</summary>

```
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -subj '/CN=lfcs.example.com' \
  -keyout /etc/ssl/private/lfcs.key \
  -out /etc/ssl/certs/lfcs.crt
chmod 600 /etc/ssl/private/lfcs.key
```{{copy}}

</details>
