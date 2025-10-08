# Launching the Server

This page covers starting the Konarr server and verifying it's running correctly. For comprehensive web interface usage, see the [Web Interface Guide](04-usage-web.md).

## Starting the Server

### Using Docker (Recommended)

```bash
# Using Docker
docker run -d \
  --name konarr-server \
  -p 9000:9000 \
  -v $(pwd)/data:/data \
  ghcr.io/42bytelabs/konarr:latest

# Using Docker Compose
docker-compose up -d konarr-server
```

### Using Pre-built Binary

```bash
# Download and extract binary
curl -L https://github.com/42ByteLabs/konarr/releases/latest/download/konarr-server-linux-x86_64.tar.gz | tar xz

# Run server
./konarr-server
```

### From Source

```bash
# Build and run from source
git clone https://github.com/42ByteLabs/konarr.git
cd konarr
cargo run --bin konarr-server
```

## Verifying Server Status

### Health Check

Test that the server is running and accessible:

```bash
# Basic health check
curl -v http://localhost:9000/api/health

# Expected response:
# HTTP/1.1 200 OK
# {"status":"healthy","version":"x.x.x"}
```

### Server Logs

Monitor server startup and operation:

```bash
# Docker logs
docker logs -f konarr-server

# Binary logs (with RUST_LOG=info)
RUST_LOG=info ./konarr-server
```

## Initial Access

### Web Interface

Open the server URL in your browser (default port 9000):

```text
http://localhost:9000
```

### First-Time Setup

1. **Web Interface**: Navigate to the web interface to verify it loads correctly
2. **Admin Account**: Create or configure admin access if required
3. **Agent Token**: Retrieve the auto-generated agent token for agent setup

For detailed web interface usage, navigation, and features, see the [Web Interface Guide](04-usage-web.md).

## Configuration

### Basic Configuration

Create a `konarr.yml` file for persistent settings:

```yaml
server:
  domain: "localhost"
  port: 9000
  scheme: "http"

data_path: "/data"
```

### Environment Variables

Override configuration with environment variables:

```bash
export KONARR_SERVER_PORT=8080
export KONARR_DATA_PATH=/custom/data/path
./konarr-server
```

For complete configuration options, see:

- [Server Configuration](03-configuration-server.md)
- [Configuration Overview](03-configuration.md)

## Next Steps

After launching the server:

1. **[Web Interface](04-usage-web.md)** - Learn to use the web interface
2. **[Agent Setup](02-agent.md)** - Configure agents to monitor containers  
3. **[Security Setup](06-security.md)** - Implement production security practices
4. **[Reverse Proxy](02-server-reverse-proxy.md)** - Set up HTTPS and production deployment
