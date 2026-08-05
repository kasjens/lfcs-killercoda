# Configure user resource limits

A line in `limits.conf`{{}} has four fields:

```
<domain>  <type>  <item>  <value>
```

`domain`{{}} is who it applies to: a username, a `@group`{{}}, or `*`{{}}. The
`type`{{}} field is either `soft`{{}} or `hard`{{}}. Then `item`{{}} is what is
being limited, and `value`{{}} is the number.

Soft against hard is the part worth understanding rather than memorising. The
soft limit is what is actually enforced right now. The hard limit is the
ceiling the user may raise their own soft limit to. An unprivileged user can
raise soft up to hard and can lower hard, but can never raise hard. So setting
only a hard limit enforces nothing by itself, and a soft limit above the hard
one cannot take effect at all.

Like `/etc/profile`{{}}, the main file is package owned and reads a drop-in
directory beside it. A file there is the tidier place for your own rules, and
the verifier accepts either.

These limits are applied by a PAM module at login, which is why a systemd
service ignores them completely. A service never logged in, so PAM never ran
for it. That is the same fact the Essential Commands domain approaches from the
other side, where the answer is `systemd.resource-control(5)`{{}}.

### Task

Cap the `deploy`{{}} user's **open file descriptors**:

1. soft limit **4096**
2. hard limit **8192**

Either `limits.conf`{{}} or a drop-in under `limits.d`{{}} counts.

<details><summary>Tip</summary>

```
man 5 limits.conf
```{{exec}}

The page lists every item name in one block. You want the one about open files,
not the one about file size. They are easy to mix up and only one of them is
about descriptors.

</details>

<details><summary>Solution</summary>

```
cat > /etc/security/limits.d/deploy.conf <<'EOF'
deploy soft nofile 4096
deploy hard nofile 8192
EOF
```{{copy}}

</details>
