# Konarr Server

The Konarr server is the central component providing the REST API, web interface, and data storage. It's built with Rust using the Rocket framework and stores data in SQLite by default.

**Server Implementation**: The server is implemented in [server/src/main.rs](https://github.com/42ByteLabs/konarr/blob/main/server/src/main.rs) with API routes in [server/src/api](https://github.com/42ByteLabs/konarr/tree/main/server/src/api) and data models in [src/models](https://github.com/42ByteLabs/konarr/tree/main/src/models).

## Installation Methods

### Docker (Recommended)

**Single Container:**

```bash
docker run -d \
  --name konarr \
  -p 9000:9000 \
  -v ./data:/data \
  -v ./config:/config \
  ghcr.io/42bytelabs/konarr:latest
```

**Key Points:**

- Server listens on port 9000
- Data persisted in `./data` (SQLite database)
- Configuration in `./config` (optional `konarr.yml`)
- Automatic database migrations on startup

### Docker Compose

For production deployments, see our [Docker Compose guide](02-server-docker-compose.md) which includes:

- Service definitions
- Volume management
- Health checks
- Upgrade procedures

### Cargo Installation

Install the server binary directly:

```bash
# Install from crates.io
cargo install konarr-server

# Run with default configuration
konarr-server

# Run with custom config
konarr-server -c ./konarr.yml
```

**Note**: Cargo installation is not recommended for production use.

### From Source (Development)

**Requirements:**

- Rust and Cargo (latest stable)
- Node.js and npm (for frontend)
- Git

**Clone and Build:**

```bash
# Clone repository with frontend submodule
git clone https://github.com/42ByteLabs/konarr.git && cd konarr
git submodule update --init --recursive

# Build frontend
cd frontend && npm install && npm run build && cd ..

# Run server (development mode)
cargo run -p konarr-server

# Or build and run release
cargo run -p konarr-server --release -- -c ./konarr.yml
```

**Development with Live Reload:**

```bash
# Watch mode for server changes
cargo watch -q -c -- cargo run -p konarr-server

# Frontend development (separate terminal)
cd frontend && npm run dev
```

This creates:

- Default config: `config/konarr.yml`
- SQLite database: `data/konarr.db`
- Server on port 8000 (development) or 9000 (production/release)

## Configuration

### Environment Variables

The server uses Figment for configuration, supporting environment variables with `KONARR_` prefix:

```bash
# Server settings
export KONARR_SERVER__PORT=9000
export KONARR_DATA_PATH=/data
export KONARR_FRONTEND__URL=https://konarr.example.com

# Database settings  
export KONARR_DATABASE__PATH=/data/konarr.db

# Security
export KONARR_SECRET=your-secret-key
```

### Configuration File

Create `konarr.yml` for persistent settings:

```yaml
server:
  host: "0.0.0.0"
  port: 9000
  data_path: "/data"
  frontend:
    url: "https://konarr.example.com"
  secret: "your-secret-key"

database:
  path: "/data/konarr.db"
  
agent:
  key: "your-agent-key"  # Optional: will be generated if not provided
```

## Agent Token Management

The server automatically generates an agent authentication key on first startup, stored as `agent.key` in ServerSettings.

### Retrieving the Agent Token

#### Method 1: Database Query

```bash
sqlite3 ./data/konarr.db "SELECT value FROM server_settings WHERE name='agent.key';"
```

#### Method 2: Configuration File

If you set the agent key in `konarr.yml`, use that value.

#### Method 3: Web UI

Access server settings through the admin interface (requires authentication).

**⚠️ Security**: Treat the agent token as a secret. Do not commit to version control or share publicly.

## Production Deployment

### Reverse Proxy Setup

See [Reverse Proxy Setup](02-server-reverse-proxy.md) for detailed configuration examples.

### Security Recommendations

- **Use HTTPS**: Configure TLS termination at the reverse proxy
- **Set frontend URL**: Update `server.frontend.url` to match external URL
- **Secure volumes**: Protect `./data` and `./config` with appropriate file permissions
- **Stable secrets**: Set `server.secret` to a strong, persistent value
- **Regular backups**: Back up the SQLite database before upgrades

### Resource Requirements

- **Minimum**: 256MB RAM, 1GB disk
- **Recommended**: 512MB+ RAM, 5GB+ disk (for SBOM storage)
- **CPU**: Scales with number of concurrent users and agent uploads

### Monitoring

Monitor server health:

```bash
# Health check endpoint
curl http://localhost:9000/api/health

# Container logs
docker logs -f konarr

# Database size
du -h ./data/konarr.db
```

---

**Next Steps**: [Configure and deploy agents](02-agent.md) to start monitoring containers.
