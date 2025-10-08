# Reverse Proxy Setup

Running Konarr behind a reverse proxy is recommended for production deployments to provide TLS termination, load balancing, and additional security features.

## Nginx

### Basic Configuration

```nginx
server {
    listen 80;
    server_name konarr.example.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name konarr.example.com;
    
    # SSL configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Proxy configuration
    location / {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # WebSocket support (if needed for future features)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }
    
    # API endpoints with longer timeouts for large SBOM uploads
    location ~ ^/api/(snapshots|upload) {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Extended timeouts for large uploads
        proxy_connect_timeout 60s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        
        # Increase client max body size for SBOM uploads
        client_max_body_size 50M;
    }
    
    # Health check endpoint
    location /api/health {
        proxy_pass http://127.0.0.1:9000;
        access_log off;
    }
}
```

### Let's Encrypt with Certbot

Automatically obtain and renew SSL certificates:

```bash
# Install certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d konarr.example.com

# Test automatic renewal
sudo certbot renew --dry-run
```

## Traefik

### Docker Compose Configuration

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"

  konarr:
    image: ghcr.io/42bytelabs/konarr:latest
    container_name: konarr
    restart: unless-stopped
    volumes:
      - ./data:/data
      - ./config:/config
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.konarr.rule=Host(`konarr.example.com`)"
      - "traefik.http.routers.konarr.tls.certresolver=letsencrypt"
      - "traefik.http.services.konarr.loadbalancer.server.port=9000"
      # Health check
      - "traefik.http.services.konarr.loadbalancer.healthcheck.path=/api/health"
      - "traefik.http.services.konarr.loadbalancer.healthcheck.interval=30s"
```

### Traefik Configuration (`traefik.yml`)

```yaml
api:
  dashboard: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

## Caddy

### Caddyfile Configuration

```caddy
konarr.example.com {
    reverse_proxy 127.0.0.1:9000 {
        header_up X-Real-IP {remote_addr}
        header_up X-Forwarded-For {remote_addr}
        header_up X-Forwarded-Proto {scheme}
        
        # Health check
        health_uri /api/health
        health_interval 30s
        health_timeout 10s
    }
    
    # Security headers
    header {
        X-Frame-Options DENY
        X-Content-Type-Options nosniff
        X-XSS-Protection "1; mode=block"
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
    }
    
    # Longer timeouts for API uploads
    @api_uploads path /api/snapshots* /api/upload*
    reverse_proxy @api_uploads 127.0.0.1:9000 {
        timeout 300s
    }
}
```

## Apache HTTP Server

### Virtual Host Configuration

```apache
<VirtualHost *:80>
    ServerName konarr.example.com
    Redirect permanent / https://konarr.example.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName konarr.example.com
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /path/to/certificate.crt
    SSLCertificateKeyFile /path/to/private.key
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    
    # Security Headers
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    # Proxy Configuration
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:9000/
    ProxyPassReverse / http://127.0.0.1:9000/
    
    # Set headers for backend
    ProxyPassReverse / http://127.0.0.1:9000/
    ProxyPassReverseMatch ^(.*)$ http://127.0.0.1:9000$1
    
    SetEnvIf X-Forwarded-Proto https HTTPS=on
</VirtualHost>
```

## HAProxy

### Load Balancing Configuration

```haproxy
global
    daemon
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend konarr_frontend
    bind *:80
    bind *:443 ssl crt /path/to/certificate.pem
    
    # Redirect HTTP to HTTPS
    redirect scheme https if !{ ssl_fc }
    
    # Security headers
    http-response set-header X-Frame-Options DENY
    http-response set-header X-Content-Type-Options nosniff
    http-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    default_backend konarr_backend

backend konarr_backend
    balance roundrobin
    
    # Health check
    option httpchk GET /api/health
    
    # Backend servers
    server konarr1 127.0.0.1:9000 check
    # server konarr2 127.0.0.1:9001 check  # Additional instances
```

## Security Considerations

### Rate Limiting

Configure rate limiting at the reverse proxy level:

**Nginx:**

```nginx
# Rate limiting configuration
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=upload:10m rate=1r/s;

location /api/ {
    limit_req zone=api burst=20 nodelay;
}

location ~ ^/api/(snapshots|upload) {
    limit_req zone=upload burst=5 nodelay;
}
```

**Traefik:**
```yaml
# Add to service labels
- "traefik.http.middlewares.ratelimit.ratelimit.burst=20"
- "traefik.http.middlewares.ratelimit.ratelimit.average=10"
- "traefik.http.routers.konarr.middlewares=ratelimit"
```

### IP Whitelisting

Restrict access to specific IP ranges:

**Nginx:**
```nginx
# Allow specific networks
allow 10.0.0.0/8;
allow 192.168.0.0/16;
allow 172.16.0.0/12;
deny all;
```

### Authentication Middleware

Add basic authentication at the proxy level:

**Nginx:**
```nginx
location / {
    auth_basic "Konarr Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9000;
}
```

## Monitoring and Logging

### Access Logs

Configure detailed logging for monitoring:

**Nginx:**
```nginx
log_format konarr_format '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '$request_time $upstream_response_time';

access_log /var/log/nginx/konarr.access.log konarr_format;
```

### Health Checks

Set up monitoring for the reverse proxy and backend:

```bash
# Simple health check script
#!/bin/bash
curl -f -s https://konarr.example.com/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "Konarr is healthy"
    exit 0
else
    echo "Konarr health check failed"
    exit 1
fi
```

## Configuration Notes

### Backend URL Configuration

Update Konarr server configuration to use the external URL:

```yaml
# konarr.yml
server:
  frontend:
    url: "https://konarr.example.com"
```

### CORS Configuration

If needed, configure CORS headers:

```nginx
# Add CORS headers if required
add_header Access-Control-Allow-Origin "https://trusted-domain.com";
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
add_header Access-Control-Allow-Headers "Authorization, Content-Type";
```
