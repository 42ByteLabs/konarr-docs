# Agent Configuration

This page documents comprehensive agent-specific configuration options, environment variables, deployment scenarios, and security considerations.

**Configuration Implementation**: Agent configuration is defined in [src/utils/config/client.rs](https://github.com/42ByteLabs/konarr/blob/main/src/utils/config/client.rs) and processed using Figment for flexible configuration management.

## Core Agent Settings

### Project Management

| Configuration | Description | Default |
|---------------|-------------|---------|
| `agent.project_id` | Target project ID for snapshots. Leave empty to auto-create projects | - |
| `agent.create` | Allow agent to automatically create projects | `true` |
| `agent.host` | Friendly hostname identifier for this agent instance | - |

### Monitoring and Scanning

| Configuration | Description | Default |
|---------------|-------------|---------|
| `agent.monitoring` | Enable Docker container monitoring mode | `false` |
| `agent.tool_auto_install` | Automatically install missing security tools | `true` |
| `agent.toolcache_path` | Directory for scanner tool binaries | `/usr/local/toolcache` |

### Connectivity

| Configuration | Description |
|---------------|-------------|
| `instance` | Konarr server URL (e.g., `https://konarr.example.com`) |
| `agent.token` | Authentication token for API access |

## Complete Configuration Example

```yaml
# Server connection
instance: "https://konarr.example.com"

# Agent configuration
agent:
  # Authentication
  token: "your-agent-token-from-server"
  
  # Project settings
  project_id: "123"  # Specific project, or "" to auto-create
  create: true       # Allow project auto-creation
  host: "production-server-01"
  
  # Monitoring settings
  monitoring: true
  scan_interval: 300  # seconds between scans
  
  # Tool management
  tool_auto_install: true
  toolcache_path: "/usr/local/toolcache"
  
  # Scanning configuration
  scan_on_start: true
  scan_on_change: true
  
  # Security tool preferences
  preferred_sbom_tool: "syft"      # syft, trivy
  preferred_vuln_tool: "grype"     # grype, trivy
  
  # Container filtering
  include_patterns:
    - "production/*"
    - "staging/*"
  exclude_patterns:
    - "*/test-*"
    - "*/temp-*"
    
  # Resource limits
  max_concurrent_scans: 3
  scan_timeout: 600  # seconds
```

## Tool Configuration

### Security Scanner Tools

```yaml
# Tool-specific configuration
tools:
  syft:
    version: "v0.96.0"
    path: "/usr/local/bin/syft"
    config:
      exclude_paths:
        - "/tmp"
        - "/var/cache"
      cataloger_scope: "all-layers"
  
  grype:
    version: "v0.74.0"
    path: "/usr/local/bin/grype"
    config:
      fail_on_severity: "high"
      ignore_fixed: false
  
  trivy:
    version: "v0.48.0"
    path: "/usr/local/bin/trivy"
    config:
      skip_db_update: false
      timeout: "10m"
```

## Environment Variables

Agent settings can be configured via environment variables with the `KONARR_AGENT_` prefix:

```bash
# Server connection
export KONARR_INSTANCE="https://konarr.example.com"
export KONARR_AGENT_TOKEN="your-agent-token"

# Project configuration
export KONARR_AGENT_PROJECT_ID="123"
export KONARR_AGENT_CREATE=true
export KONARR_AGENT_HOST="production-server-01"

# Monitoring settings
export KONARR_AGENT_MONITORING=true
export KONARR_AGENT_SCAN_INTERVAL=300

# Tool management
export KONARR_AGENT_TOOL_AUTO_INSTALL=true
export KONARR_AGENT_TOOLCACHE_PATH="/usr/local/toolcache"

# Resource settings
export KONARR_AGENT_MAX_CONCURRENT_SCANS=3
export KONARR_AGENT_SCAN_TIMEOUT=600
```

## Container Agent Configuration

### Docker Socket Access

When running agent in a container with Docker monitoring:

```yaml
# Security warning: Docker socket access grants significant privileges
agent:
  monitoring: true
  docker_socket: "/var/run/docker.sock"
  
  # Security controls
  docker_security:
    require_readonly: true
    filter_by_labels: true
    allowed_networks:
      - "production"
      - "staging"
```

### Environment Variables for Containers

```bash
# Core settings
export KONARR_INSTANCE="https://konarr.example.com"
export KONARR_AGENT_TOKEN="your-token"
export KONARR_AGENT_MONITORING=true

# Container-specific paths
export KONARR_AGENT_TOOLCACHE_PATH="/usr/local/toolcache"

# Security settings
export KONARR_AGENT_DOCKER_SOCKET="/var/run/docker.sock"
export KONARR_AGENT_SECURITY_READONLY=true
```

## Production Agent Deployment

### High-Security Environment

```yaml
# Air-gapped or high-security configuration
agent:
  tool_auto_install: false  # Disable auto tool installation
  toolcache_path: "/opt/security-tools"
  
  # Pre-approved tool versions
  tools:
    syft:
      path: "/opt/security-tools/syft"
      version: "v0.96.0"
      checksum: "sha256:abc123..."
    grype:
      path: "/opt/security-tools/grype"
      version: "v0.74.0"
      checksum: "sha256:def456..."
  
  # Strict scanning policies
  scan_config:
    fail_on_error: true
    require_signature_verification: true
    max_scan_size: "1GB"
    timeout: 300
```

### Multi-Environment Agent

```yaml
# Development/staging/production agent
agent:
  host: "${ENVIRONMENT}-server-${HOSTNAME}"
  project_id: "${KONARR_PROJECT_ID}"
  
  # Environment-specific settings
  monitoring: true
  scan_interval: 600  # 10 minutes
  
  # Conditional scanning based on environment
  scan_filters:
    development:
      scan_on_change: true
      include_test_images: true
    production:
      scan_on_change: false
      scan_schedule: "0 2 * * *"  # Daily at 2 AM
      exclude_test_images: true
```

## Agent Authentication and Security

### Token Management

```bash
# Retrieve agent token from server
export AGENT_TOKEN=$(curl -s -X GET \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  https://konarr.example.com/api/admin/settings | \
  jq -r '.settings.agentKey')

export KONARR_AGENT_TOKEN="${AGENT_TOKEN}"
```

### Security Best Practices

1. **Rotate tokens regularly**: Generate new agent tokens periodically
2. **Limit permissions**: Use dedicated service accounts for agents
3. **Network security**: Restrict agent network access to Konarr server only
4. **Audit logging**: Enable detailed logging for agent activities
5. **Resource limits**: Set appropriate CPU/memory limits for agent containers

---

For more information, see:

- [Complete Configuration Guide](03-configuration.md)
- [Server Configuration](03-configuration-server.md)
- [CLI Usage](03-usage-cli.md)

```bash
export KONARR_AGENT_URL=<http://konarr.example.com:9000>
export KONARR_AGENT_TOKEN=your-token-here
```

## Tooling and installation

- The agent will look for `syft`, `grype`, or `trivy` on `PATH` and in `agent.toolcache_path`.
- For secure environments, pre-install approved tool versions into `agent.toolcache_path` and set `agent.tool_auto_install` to `false`.

If you'd like, I can add a short Kubernetes manifest to demonstrate setting these env vars in a Pod spec.
