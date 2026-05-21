# Local Wildcard DNS Configuration for a Specific Domain

⚠️ **WARNING:** This configuration can leave your machine without internet access if not done correctly. Make sure dnsmasq is configured to forward non-local DNS queries to upstream servers.

This document explains how to make a private domain name (for example
`domain-local.com` and all its subdomains) resolve to `127.0.0.1` on your machine
without interfering with internet resolution for other domains. The trick is
to use **dnsmasq** to resolve the wildcard and **systemd-resolved** to forward
only queries for that domain to dnsmasq.

The solution works on Ubuntu 22.04/23.04 (and other distributions that use
`systemd-resolved`).

## Verification Before Applying Changes

Before executing the commands, verify that you have internet connectivity:

```bash
# Test current resolution
dig google.com +short

# Verify that systemd-resolved is working
resolvectl status | grep "DNS Servers"
```

If you lose internet after applying the changes, immediately execute:

```bash
# Immediate reset
sudo resolvectl dns lo ""
sudo resolvectl domain lo ""
sudo systemctl stop dnsmasq
```

## Steps

1. **Install dnsmasq** (if you haven't already):

   ```bash
   sudo apt update
   sudo apt install -y dnsmasq
   ```

   if the service doesn't start because port 53 is already occupied by
   `systemd-resolved`, it doesn't matter; dnsmasq will listen on another IP.

2. **Configure dnsmasq for wildcard** and listen on `127.0.0.2` (avoiding
   systemd's 127.0.0.53). **IMPORTANT:** dnsmasq must forward queries
   it doesn't know to real DNS servers to avoid losing internet access.

   **Why 127.0.0.2?** systemd-resolved uses 127.0.0.53 as its stub resolver.
   We use 127.0.0.2 so dnsmasq doesn't conflict.

   ```bash
   sudo tee /etc/dnsmasq.d/99-local.conf <<'EOF'
listen-address=127.0.0.2
address=/.domain-local.com/127.0.0.1
# Forward non-local queries to system DNS servers
server=8.8.8.8
server=1.1.1.1
EOF

   # Restart the service
   sudo systemctl restart dnsmasq
   ```

   The above file makes any query to `*.domain-local.com`
   return `127.0.0.1`, and the rest of queries are forwarded to Google DNS
   (8.8.8.8) and Cloudflare DNS (1.1.1.1).

3. **Tell the resolver to forward that domain to dnsmasq**:

   In modern Ubuntu versions the utility is called `resolvectl` instead of
   `systemd-resolve`. Use one of the following commands depending on what you have
   available (the first one will be necessary on Ubuntu 22.04/23.04):

   ```bash
   # if you have resolvectl (normal)
   # use the loopback interface ("lo"). resolvectl needs a valid link,
# not an IP address; the name "lo" is the loopback device in most
# systems.
   sudo resolvectl dns lo 127.0.0.2
   sudo resolvectl domain lo domain-local.com

   # old name (some distros still install it)
   # sudo systemd-resolve --set-dns=127.0.0.2 --set-domain=domain-local.com
   ```

   you can check the configuration with:

   ```bash
   resolvectl domain
   resolvectl status
   ```

   the `link 2` line (or active interface) should show `domain-local.com` as
   domain associated with 127.0.0.2.

4. **Test**

   ```bash
   dig @127.0.0.53 dkron.domain-local.com +short    # should return 127.0.0.1
   dig @127.0.0.53 google.com +short               # continues resolving
   ```

   (127.0.0.53 is the stub resolver of `systemd-resolved`).

## Troubleshooting

### If you lose internet access after configuration:

1. **Verify dnsmasq configuration:**
   ```bash
   cat /etc/dnsmasq.d/99-local.conf
   ```
   It should have the lines `server=8.8.8.8` and `server=1.1.1.1`.

2. **Restart dnsmasq:**
   ```bash
   sudo systemctl restart dnsmasq
   ```

3. **Verify dnsmasq is working:**
   ```bash
   sudo systemctl status dnsmasq
   ```

4. **Test direct resolution:**
   ```bash
   dig @127.0.0.2 google.com +short  # Should work
   ```

5. **If nothing works, undo the changes:**
   ```bash
   sudo resolvectl dns lo ""
   sudo resolvectl domain lo ""
   sudo systemctl stop dnsmasq
   sudo apt remove --purge dnsmasq
   ```

### Verify current configuration:

```bash
# View resolved configuration
resolvectl status

# View dnsmasq configuration
sudo systemctl status dnsmasq
sudo netstat -tlnp | grep :53
```

5. **mkcert (optional)**

   if you want HTTPS locally for these names, generate a wildcard certificate
   with mkcert. Make sure the directories exist:

   ```bash
   mkdir -p docker-compose/nginx/letsencrypt/certs

   mkcert -cert-file docker-compose/nginx/letsencrypt/certs/fullchain.pem \
         -key-file docker-compose/nginx/letsencrypt/certs/privkey.pem \
         '*.domain-local.com' 'domain-local.com' localhost 127.0.0.1 ::1
   ```

6. **Use with Docker**

   now your containers and services can advertise `VIRTUAL_HOST`
   as, for example, `dkron.domain-local.com` and `nginx-proxy` / companion
   will handle the connections normally. The rest of internet resolution
   is not affected.

## Undo Changes

To remove the forwarding from `systemd-resolved`:

```bash
# Reset DNS for the lo interface
sudo resolvectl dns lo ""
sudo resolvectl domain lo ""

# Or using the old command if available
sudo systemd-resolve --reset-dns=lo
sudo systemd-resolve --reset-domain=lo
```

To completely uninstall dnsmasq:

```bash
sudo systemctl stop dnsmasq
sudo apt remove --purge dnsmasq
sudo rm /etc/dnsmasq.d/99-local.conf
```
sudo systemctl restart dnsmasq
```

Si quieres parar completamente dnsmasq:

```bash
sudo systemctl stop dnsmasq
sudo systemctl disable dnsmasq
```

---

With this configuration, you can have a local wildcard `*.domain-local.com`
without disconnecting the rest of the internet.
