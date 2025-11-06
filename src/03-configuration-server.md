# Server Configuration

This page documents comprehensive server-specific configuration options, environment variable mappings, and production deployment examples.

**Configuration Implementation**: Server configuration is managed through Figment and defined in [src/utils/config/server.rs](https://github.com/42ByteLabs/konarr/blob/main/src/utils/config/server.rs) and [src/utils/config/config.rs](https://github.com/42ByteLabs/konarr/blob/main/src/utils/config/config.rs).

---

## Core Server Settings

### Network Configuration

| Configuration | Description | Default |
|---------------|-------------|---------|
| `server.domain` | Server domain/hostname | `localhost` |
| `server.port` | HTTP port | `9000` |
| `server.scheme` | URL scheme, `http` or `https` | `http` |
| `server.cors` | Enable CORS for API access | `true` |
| `server.api` | API endpoint prefix | `/api` |

### Security Settings

| Configuration | Description |
|---------------|-------------|
| `server.secret` | Application secret for sessions and JWT tokens. **Required for production** |
| `agent.key` | Agent authentication token. Auto-generated if not provided |

### Data and Storage

| Configuration | Description | Default |
|---------------|-------------|---------|
| `data_path` | Directory for SQLite database and application data | `/data` |
| `server.frontend` | Path to frontend static files | `frontend/build` |

### URL Configuration

| Configuration | Description |
|---------------|-------------|
| `server.frontend.url` | Externally accessible URL for generating links in emails and redirects |

## Complete Configuration Example

```yaml
# Complete server configuration
server:
  # Network settings
  domain: "konarr.example.com"
  port: 9000
  scheme: "https"
  cors: true
  api: "/api"
  
  # Security settings
  secret: "your-very-strong-secret-key-here"
  
  # Frontend configuration
  frontend: "/app/dist"
  
# Data storage
data_path: "/var/lib/konarr"

# Database configuration
database:
  path: "/var/lib/konarr/konarr.db"
  token: null  # For remote databases

# Session configuration
sessions:
  admins:
    expires: 1    # hours
  users:
    expires: 24   # hours
  agents:
    expires: 360  # hours

# Agent authentication
agent:
  key: "your-agent-token"  # Auto-generated if not provided
```

## Advanced Server Settings

### Cleanup Configuration

```yaml
# Automatic cleanup settings
cleanup:
  enabled: true
  timer: 90  # days to keep old snapshots
```

### Security Features

```yaml
# Security scanning and vulnerability management
security:
  enabled: true
  rescan: true
  advisories_pull: true
```

### Registration Settings

```yaml
# User registration control
registration:
  enabled: false  # Disable public registration
```

## Environment Variables

All server settings can be overridden with environment variables using the `KONARR_SERVER_` prefix:

```bash
# Network configuration
export KONARR_SERVER_DOMAIN=konarr.example.com
export KONARR_SERVER_PORT=9000
export KONARR_SERVER_SCHEME=https
export KONARR_SERVER_CORS=true

# Security settings
export KONARR_SERVER_SECRET="your-production-secret"

# Data paths
export KONARR_DATA_PATH=/var/lib/konarr
export KONARR_DB_PATH=/var/lib/konarr/konarr.db

# Frontend configuration
export KONARR_SERVER_FRONTEND=/app/dist
export KONARR_CLIENT_PATH=/app/dist
```

## Database Configuration

### SQLite (Default)

```yaml
database:
  path: "/var/lib/konarr/konarr.db"
```

### Remote Database (LibSQL/Turso)

```yaml
database:
  path: "libsql://your-database-url"
  token: "your-database-token"
```

Environment variables:

```bash
export KONARR_DB_PATH="libsql://your-database-url"
export KONARR_DB_TOKEN="your-database-token"
```

## Production Deployment Settings

### Minimal Production Configuration

```yaml
server:
  domain: "konarr.yourdomain.com"
  port: 9000
  scheme: "https"
  secret: "$(openssl rand -base64 32)"

data_path: "/var/lib/konarr"

database:
  path: "/var/lib/konarr/konarr.db"

sessions:
  admins:
    expires: 8   # 8 hours for admin sessions
  users:
    expires: 24  # 24 hours for user sessions

cleanup:
  enabled: true
  timer: 30    # Keep snapshots for 30 days

registration:
  enabled: false  # Disable public registration

security:
  enabled: true
```

## Container-Specific Settings

When running in containers, these environment variables are commonly used:

```bash
# Rocket framework settings
export ROCKET_ADDRESS=0.0.0.0
export ROCKET_PORT=9000

# Konarr-specific paths
export KONARR_DATA_PATH=/data
export KONARR_DB_PATH=/data/konarr.db
export KONARR_SERVER_FRONTEND=/app/dist

# Security
export KONARR_SERVER_SECRET="$(openssl rand -base64 32)"
```

---

For more information, see:

- [Complete Configuration Guide](03-configuration.md)
- [Agent Configuration](03-configuration-agent.md)
- [CLI Usage](03-usage-cli.md)

```bash
export KONARR_DATA_PATH=/data
export KONARR_FRONTEND__URL=<https://konarr.example.com>
```

The project's config merging uses Figment, which supports nesting via separators (commonly `__` in environment names). If an env mapping does not take effect, prefer using `konarr.yml` or CLI flags.

## Persistence and backups

- Mount a host directory under `/data` in container deployments to persist the SQLite DB (`data/konarr.db`).
- Regularly back up the DB file before upgrades: `cp data/konarr.db data/konarr.db.bak`.

---

**Additional Resources:**

- [Server Installation](./02-server.md) - Server deployment methods
- [Reverse Proxy Setup](./02-server-reverse-proxy.md) - Production proxy configuration
- [Security](./06-security.md) - Security best practices
