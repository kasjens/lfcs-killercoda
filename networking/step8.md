# Implement reverse proxies and load balancers

A reverse proxy accepts connections on behalf of a backend. That gives you one
TLS termination point, one access log, and a place to balance across several
backends.

`proxy_pass`{{}} is the whole of the forwarding. The subtlety is what the
backend then sees, and two headers matter enough that omitting them is a bug
rather than a preference.

**`Host`{{}}.** By default the backend receives the Host header nginx used for
the upstream connection, not the one the client sent. Applications build
absolute URLs from Host, so redirects and links come out pointing at
`127.0.0.1:3000`{{}} instead of the real site. Forwarding the original fixes
it.

**`X-Forwarded-For`{{}}.** Every connection arrives from the proxy, so the
backend's logs, rate limiting and geolocation all see one address. This header
carries the original client, and `$proxy_add_x_forwarded_for`{{}} appends to
any existing chain rather than overwriting it.

A trailing slash on `proxy_pass`{{}} changes the semantics: with one, the
matched location prefix is stripped before forwarding; without, the full path
is passed. That single character is a common source of 404s.

For load balancing, an `upstream`{{}} block lists several servers and
`proxy_pass`{{}} names the block instead of a host. Default distribution is
round robin; `least_conn`{{}} and `ip_hash`{{}} are the other two worth
knowing, the last giving session stickiness by client address.

Debian and Ubuntu split sites into `sites-available`{{}} and
`sites-enabled`{{}}, where the second holds symlinks. **A file in
`sites-available`{{}} alone does nothing.** `nginx -t`{{}} validates the whole
configuration and is what you run before any reload.

There is no backend on this box, so the check reads your site and asks nginx to
validate it.

### Task

Create a site at **`/etc/nginx/sites-available/lfcs`{{}}** and enable it:

1. Listen on **8080**.
2. Proxy `/`{{}} to **`http://127.0.0.1:3000`{{}}**.
3. Forward the original **`Host`{{}}** header.
4. Set **`X-Forwarded-For`{{}}** so the backend can see the client address.

<details><summary>Tip</summary>

```
man nginx
```{{exec}}

`nginx(8)`{{}} is the binary: eight command-line flags, no directives. There is
no directive reference on the box either — `/usr/share/doc/nginx`{{}} is a
changelog and a copyright file, and the default site shows `server`{{}},
`listen`{{}} and `location`{{}} but never proxies anything. So this one is not
a man page problem, and knowing that early is worth more than another search.

What the box does have is its own configuration, which was written by people
who knew the directives:

```
cat /etc/nginx/proxy_params
grep -w proxy_pass /usr/share/vim/addons/syntax/nginx.vim
```{{exec}}

`proxy_params`{{}} is the two headers this task asks for, already written out
correctly — Debian ships it precisely because everyone needs them. The vim
syntax file is the whole directive vocabulary, which settles "is it
`proxy_header`{{}} or `proxy_set_header`{{}}" without a guess.

Enable by symlinking into `sites-enabled`{{}}, then `nginx -t`{{}}.

</details>

<details><summary>Solution</summary>

```
cat > /etc/nginx/sites-available/lfcs <<'EOF'
server {
  listen 8080;
  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
EOF
ln -sf /etc/nginx/sites-available/lfcs /etc/nginx/sites-enabled/lfcs
nginx -t
```{{copy}}

</details>
