# SSL/TLS Configuration Guide

This guide covers the SSL/TLS configuration implemented in the ADempiere UI Gateway stack using nginx-proxy and Let's Encrypt ACME Companion.

## Overview

The stack includes automatic SSL certificate management with:
- **nginx-proxy**: Reverse proxy that automatically handles SSL termination
- **acme-companion**: Companion container that manages certificate issuance and renewal
- **Let's Encrypt**: Free SSL certificates with automatic renewal

## Architecture

```
Internet → nginx-proxy (443/80) → Services
                    ↓
            acme-companion (certificate management)
```

## Configuration Files

### docker-compose.yml

The SSL services are configured in `docker-compose.yml`:

```yaml
# Reverse proxy with SSL termination
nginx-proxy:
  image: nginxproxy/nginx-proxy:1.10.0-alpine
  container_name: ${NGINX_LETSENCRYPT_PROXY_CONTAINER_NAME}
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - ./nginx/letsencrypt/certs:/etc/nginx/certs:rw
    - ./nginx/letsencrypt/vhost.d:/etc/nginx/vhost.d:rw
    - ./nginx/letsencrypt/html:/usr/share/nginx/html:rw
    - ./nginx/letsencrypt/conf.d:/etc/nginx/conf.d:ro
  labels:
    - "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy=true"

# Certificate management
letsencrypt-acme:
  image: nginxproxy/acme-companion:2.6.3
  container_name: ${NGINX_LETSENCRYPT_ACME_CONTAINER_NAME}
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - volume_nginx_acme:/etc/acme.sh
    - ./nginx/letsencrypt/certs:/etc/nginx/certs:rw
  environment:
    - DEFAULT_EMAIL=${NGINX_LETSENCRYPT_EMAIL}
    - NGINX_PROXY_CONTAINER=${NGINX_LETSENCRYPT_PROXY_CONTAINER_NAME}
  depends_on:
    - nginx-proxy
```

### env_template.env

SSL-related environment variables:

```bash
# Domain configuration
HOST_IP=erp-adempiere.westfalia-it.com

# SSL certificate settings
NGINX_LETSENCRYPT_EMAIL=admin@${HOST_IP}
NGINX_LETSENCRYPT_PROXY_IMAGE=nginxproxy/nginx-proxy:1.10.0-alpine
NGINX_LETSENCRYPT_ACME_IMAGE=nginxproxy/acme-companion:2.6.3
NGINX_LETSENCRYPT_PROXY_CONTAINER_NAME=${COMPOSE_PROJECT_NAME}.nginx-proxy
NGINX_LETSENCRYPT_ACME_CONTAINER_NAME=${COMPOSE_PROJECT_NAME}.letsencrypt-acme
```

## Service Configuration

Each service that needs SSL includes these environment variables:

```yaml
environment:
  VIRTUAL_HOST: service.${HOST_IP},www.service.${HOST_IP}
  VIRTUAL_PORT: 8080
  LETSENCRYPT_HOST: service.${HOST_IP},www.service.${HOST_IP}
  LETSENCRYPT_EMAIL: ${NGINX_LETSENCRYPT_EMAIL}
```

## SSL-Enabled Services

| Service | Container Name | Virtual Host | Port |
|---------|----------------|--------------|------|
| Main Gateway | ui-gateway | `erp-adempiere.westfalia-it.com` | 80 |
| MinIO | s3-storage | `minio.erp-adempiere.westfalia-it.com` | 9000 |
| ZK UI | adempiere-zk | `zk.erp-adempiere.westfalia-it.com` | 8080 |
| Vue UI | vue-ui | `vue.erp-adempiere.westfalia-it.com` | 80 |
| DKron | dkron-scheduler | `dkron.erp-adempiere.westfalia-it.com` | 8080 |
| Kafdrop | kafdrop | `kafdrop.erp-adempiere.westfalia-it.com` | 9000 |
| OpenSearch | opensearch-dashboards | `opensearch.erp-adempiere.westfalia-it.com` | 5601 |

## How It Works

1. **Container Startup**: nginx-proxy starts and listens on ports 80/443
2. **Service Registration**: Services with `VIRTUAL_HOST` environment variables register with nginx-proxy
3. **Certificate Request**: acme-companion detects new domains and requests certificates from Let's Encrypt
4. **ACME Challenge**: HTTP-01 challenges are served via port 80
5. **Certificate Installation**: Certificates are installed in nginx-proxy
6. **SSL Termination**: nginx-proxy terminates SSL and forwards traffic to services

## Certificate Management

### Automatic Renewal

Certificates are renewed automatically when they expire (typically 90 days).

### Manual Operations

**Check certificate status:**
```bash
docker exec adempiere-ui-gateway.letsencrypt-acme /app/cert_status
```

**Force renewal:**
```bash
docker exec adempiere-ui-gateway.letsencrypt-acme /app/force_renew
```

**View certificate info:**
```bash
docker exec adempiere-ui-gateway.nginx-proxy cat /etc/nginx/certs/erp-adempiere.westfalia-it.com.crt | openssl x509 -text -noout
```

### Certificate Storage

- **Host directory**: `./nginx/letsencrypt/certs/`
- **Container directory**: `/etc/nginx/certs/`
- **ACME data**: Docker volume `volume_nginx_acme`

## DNS Requirements

For production SSL certificates:

1. **Domain ownership**: Domain must point to server IP
2. **DNS records**:
   ```
   erp-adempiere.westfalia-it.com     A     YOUR_SERVER_IP
   *.erp-adempiere.westfalia-it.com   A     YOUR_SERVER_IP
   ```

## Local Development

For local testing with custom domains:

### Option 1: Self-Signed Certificates with mkcert

```bash
# Install mkcert
sudo apt install mkcert
mkcert -install

# Generate certificates
mkcert "*.domain-local.com" domain-local.com

# Copy to nginx directory
cp *.pem ./nginx/letsencrypt/certs/
```

### Option 2: Disable SSL for Development

Remove `LETSENCRYPT_*` environment variables from services for HTTP-only operation.

## Troubleshooting

### Certificate Not Issued

**Symptoms:**
- HTTPS URLs return connection errors
- acme-companion logs show certificate request failures

**Solutions:**
1. Check DNS resolution: `dig erp-adempiere.westfalia-it.com`
2. Verify ports 80/443 are open in firewall
3. Check acme-companion logs: `docker logs adempiere-ui-gateway.letsencrypt-acme`

### Mixed Content Warnings

**Symptoms:**
- Browser shows "mixed content" warnings
- Some resources load over HTTP instead of HTTPS

**Solutions:**
1. Ensure all internal links use relative URLs or HTTPS
2. Check nginx configuration for protocol redirects
3. Verify `VIRTUAL_HOST` and `LETSENCRYPT_HOST` are consistent

### Certificate Expired

**Symptoms:**
- Browser shows certificate expired errors

**Solutions:**
1. acme-companion should renew automatically
2. Manual renewal: `docker exec adempiere-ui-gateway.letsencrypt-acme /app/force_renew`
3. Check renewal logs for errors

### Port Conflicts

**Symptoms:**
- nginx-proxy fails to start with port binding errors

**Solutions:**
1. Check if other services are using ports 80/443
2. Stop conflicting services: `sudo systemctl stop apache2`
3. Use different ports if needed (not recommended for production)

## Security Considerations

### Certificate Authority

- Uses Let's Encrypt (trusted by all major browsers)
- Automatic renewal prevents expired certificates
- No manual certificate management required

### Cipher Suites

nginx-proxy uses modern, secure cipher suites by default:
- TLS 1.2 and 1.3 support
- Strong cipher suites (AES-GCM, ChaCha20-Poly1305)
- Perfect forward secrecy

### HSTS Headers

- Automatic `Strict-Transport-Security` headers
- Forces browsers to use HTTPS for future requests
- Protects against protocol downgrade attacks

## Migration from HTTP

To enable SSL on an existing HTTP-only installation:

1. **Update domain**: Set `HOST_IP` in `env_template.env`
2. **Configure DNS**: Point domain to server IP
3. **Start with SSL**: `./start-all.sh -d all`
4. **Update bookmarks**: Change HTTP URLs to HTTPS
5. **Test services**: Verify all services work with HTTPS

## Performance Impact

- **Minimal overhead**: SSL termination is hardware-accelerated
- **Certificate caching**: nginx-proxy caches certificates in memory
- **No service impact**: SSL termination happens at proxy level

## Monitoring

### Health Checks

Monitor SSL certificate status:

```bash
# Check certificate expiration
openssl s_client -connect erp-adempiere.westfalia-it.com:443 -servername erp-adempiere.westfalia-it.com 2>/dev/null | openssl x509 -noout -dates

# Check SSL rating
curl -s "https://www.ssllabs.com/ssltest/analyze.html?d=erp-adempiere.westfalia-it.com" | grep -o 'rating.*'
```

### Logs

```bash
# nginx-proxy logs
docker logs adempiere-ui-gateway.nginx-proxy

# acme-companion logs
docker logs adempiere-ui-gateway.letsencrypt-acme
```

## Advanced Configuration

### Custom nginx Configuration

Add custom nginx configuration per virtual host:

```bash
# Create custom config file
echo "client_max_body_size 100M;" > ./nginx/letsencrypt/vhost.d/erp-adempiere.westfalia-it.com

# Restart nginx-proxy
docker restart adempiere-ui-gateway.nginx-proxy
```

### Wildcard Certificates

For wildcard certificates, use DNS-01 challenge (requires DNS API access).

### Custom Certificate Authorities

For internal CA certificates, mount them manually:

```yaml
volumes:
  - ./custom-ca.crt:/etc/nginx/certs/ca.crt:ro
```

## Support

For SSL-related issues:

1. Check this documentation
2. Review container logs
3. Verify DNS and firewall configuration
4. Test with online SSL checkers (SSL Labs, etc.)

## References

- [nginx-proxy documentation](https://github.com/nginx-proxy/nginx-proxy)
- [acme-companion documentation](https://github.com/nginx-proxy/acme-companion)
- [Let's Encrypt documentation](https://letsencrypt.org/docs/)
