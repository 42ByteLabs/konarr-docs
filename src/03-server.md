# Server Configuration

This section covers the basic configuration and setup of the Konarr server. The server is the central component that provides the REST API, web interface, and data storage capabilities.

## Quick Start

### Basic Configuration File

Create a `konarr.yml` configuration file:

```yaml
# Basic server configuration
server:
  domain: "localhost"
  port: 9000
  scheme: "http"
  secret: "your-secure-secret-key-here"

# Data storage location
data_path: "./data"

# Agent authentication
agent:
  key: "your-agent-key-here"
```

### Running the Server

Start the server with your configuration:

```bash
# Using Docker (recommended)
docker run -d \
  --name konarr-server \
  -p 9000:9000 \
  -v $(pwd)/konarr.yml:/app/konarr.yml \
  -v $(pwd)/data:/data \
  ghcr.io/42bytelabs/konarr:latest

# Using binary
konarr-server --config konarr.yml

# Using cargo (development)
cargo run --bin konarr-server -- --config konarr.yml
```

## Essential Configuration

### Network Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `server.domain` | Server hostname | `localhost` |
| `server.port` | HTTP port | `9000` |
| `server.scheme` | Protocol (http/https) | `http` |

### Security Settings

| Setting | Description | Required |
|---------|-------------|----------|
| `server.secret` | Application secret for sessions | **Yes** |
| `agent.key` | Agent authentication token | Optional |

### Storage Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `data_path` | Database and data directory | `./data` |

## Verification

### Health Check

Verify your server is running correctly:

```bash
# Test server health
curl http://localhost:9000/api

# Expected response includes server version and status
```

### Web Interface

Access the web interface at: `http://localhost:9000`

## Next Steps

- **[Launching the Server](./03-launching-server.md)** - Detailed startup procedures and verification
- **[Server Configuration Details](./03-configuration-server.md)** - Complete configuration reference
- **[Web Interface](./04-usage-web.md)** - Using the web dashboard

## Common Issues

### Database Initialization

The server automatically creates the SQLite database on first run. Ensure the `data_path` directory is writable.

### Port Conflicts

If port 9000 is in use, change `server.port` in your configuration file or use Docker port mapping.
