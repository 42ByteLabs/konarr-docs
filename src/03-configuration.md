# Configuration & Usage

This page provides an overview of Konarr configuration and common usage workflows for the Server, Web UI, and Agent (CLI).

## Configuration Sources and Precedence

Konarr uses a configuration merging strategy (Figment in the server code):

1. `konarr.yml` configuration file (if present)
2. Environment variables
3. Command-line flags (where present)

Environment variables are supported and commonly used for container deployments. The server and agent use prefixed environment variables to avoid collisions:

- Server-wide env vars: prefix with `KONARR_` (e.g., `KONARR_DATA_PATH`, `KONARR_DATABASE_URL`)
- Agent-specific env vars: prefix with `KONARR_AGENT_` (e.g., `KONARR_AGENT_TOKEN`, `KONARR_AGENT_MONITORING`)

### Container Defaults

Packaged defaults (container images):

- Data path: `/data` (exposed as `KONARR_DATA_PATH=/data`)
- Config file path: `/config/konarr.yml` (mount `/config` to provide `konarr.yml`)
- HTTP port: 9000

---

## Configuration Overview

Konarr configuration is organized into several main sections:

### Server Configuration

The server configuration controls the web interface, API, database, and security settings.

**Key areas:**

- Network settings (domain, port, scheme)
- Security settings (secrets, authentication)
- Database configuration
- Frontend configuration
- Session management

For detailed server configuration, see: **[Server Configuration](03-configuration-server.md)**

### Agent Configuration

The agent configuration controls how agents connect to the server, which projects they target, and how they scan containers.

**Key areas:**

- Server connectivity and authentication
- Project targeting and auto-creation
- Docker monitoring and scanning
- Security tool management
- Resource limits and filtering

For detailed agent configuration, see: **[Agent Configuration Overview](03-agent.md)**

### Sample Complete Configuration

```yaml
# Basic konarr.yml example
server:
  domain: "konarr.example.com"
  port: 9000
  scheme: "https"
  secret: "your-secret-key"

data_path: "/var/lib/konarr"

database:
  path: "/var/lib/konarr/konarr.db"

agent:
  token: "your-agent-token"
  project_id: "123"
  monitoring: true
  tool_auto_install: true

sessions:
  admins:
    expires: 8
  users:
    expires: 24
```

---

## CLI Usage (konarr-cli)

### Global Flags

| Argument | Description |
|----------|-------------|
| `--config <path>` | Path to a `konarr.yml` configuration file |
| `--instance <url>` | Konarr server URL (example: `http://your-server:9000`) |
| `--agent-token <token>` | Agent token for authentication (or use `KONARR_AGENT_TOKEN` env var) |
| `--debug` | Enable debug logging |
| `--project-id <id>` | Project ID for operations |

### Common Subcommands

| Subcommand | Description |
|------------|-------------|
| `agent` | Run the agent in monitoring mode with optional `--docker-socket` |
| `scan` | Scan container images with `--image`, `--list`, `--output` |
| `upload-sbom` | Upload SBOM file with `--input`, `--snapshot-id` |
| `database` | Database operations (create, user, cleanup) |
| `tasks` | Run maintenance tasks |

### Agent Example

```bash
# Run agent with Docker socket monitoring
konarr-cli --instance http://your-server:9000 --agent-token <AGENT_TOKEN> agent --docker-socket /var/run/docker.sock
```

### Scan Example

```bash
# Scan a container image
konarr-cli --instance http://your-server:9000 --agent-token <AGENT_TOKEN> scan --image alpine:latest

# List available tools
konarr-cli scan --list
```

Enable debug logging for troubleshooting with `--debug` flag.

---

## Configuration Validation

### Test Configuration

Before deploying to production, validate your configuration:

```bash
# Test server configuration (development)
cargo run -p konarr-server -- --config konarr.yml

# Test agent with debug logging
konarr-cli --config konarr.yml --debug agent

# Check configuration loading
konarr-cli --config konarr.yml --debug
```

### Environment Variable Check

```bash
# List all Konarr environment variables
env | grep KONARR_ | sort

# Run with debug to see configuration loading
konarr-cli --debug
```

---

## Additional Resources

For detailed configuration options and examples:

- **[Server Configuration](03-configuration-server.md)** — Complete server settings, production deployment, and environment variables
- **[Agent Configuration](03-configuration-agent.md)** — Agent settings, tool configuration, and deployment scenarios
- **[Web Interface Guide](04-usage-web.md)** — Complete web interface usage and navigation guide
- **[CLI Usage Examples](03-usage-cli.md)** — Practical usage examples and workflows
- **[Security Setup](06-security.md)** — Authentication, tokens, and security best practices
- **[Troubleshooting Guide](07-troubleshooting.md)** — Common issues, debugging, and performance optimization

For additional help, see the [troubleshooting guide](07-troubleshooting.md) or visit the [Konarr GitHub repository](https://github.com/42ByteLabs/konarr).
