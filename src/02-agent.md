# Konarr Agent

The Konarr Agent (`konarr-cli`) is a Rust-based command-line tool that monitors containers, generates SBOMs, and uploads security data to the Konarr server. It can run as a one-shot scanner or in continuous monitoring mode.

## Installation Methods

### Docker (Recommended)

**Basic Agent Run:**

```bash
docker run -it --rm \
  -e KONARR_INSTANCE="http://your-server:9000" \
  -e KONARR_AGENT_TOKEN="<AGENT_TOKEN>" \
  -e KONARR_PROJECT_ID="<PROJECT_ID>" \
  ghcr.io/42bytelabs/konarr-agent:latest
```

**Container Monitoring Mode:**

```bash
docker run -d \
  --name konarr-agent \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e KONARR_INSTANCE="http://your-server:9000" \
  -e KONARR_AGENT_TOKEN="<AGENT_TOKEN>" \
  -e KONARR_AGENT_MONITORING=true \
  -e KONARR_AGENT_AUTO_CREATE=true \
  ghcr.io/42bytelabs/konarr-agent:latest
```

**🔐 Security Warning**: Mounting the Docker socket (`/var/run/docker.sock`) grants the container significant control over the host system. This includes the ability to:

- Create privileged containers
- Access host filesystem through volume mounts  
- Escalate privileges
- Inspect all running containers

**Security Mitigations:**

- Only run on trusted hosts with trusted images
- Use read-only mounts when possible (`:ro`)
- Consider using a dedicated host agent instead of containerized agent
- Limit agent runtime permissions
- Monitor agent activity closely
- Consider using container runtimes with safer introspection APIs

### Cargo Installation

Install the CLI binary directly:

```bash
# Install from crates.io
cargo install konarr-cli

# Run agent
konarr-cli --instance http://your-server:9000 \
  --agent-token <AGENT_TOKEN> \
  agent --docker-socket /var/run/docker.sock

# One-shot scan
konarr-cli --instance http://your-server:9000 \
  --agent-token <AGENT_TOKEN> \
  scan --image alpine:latest
```

## Specialized Agent Images

**Syft-only Agent:**

```dockerfile
FROM ghcr.io/42bytelabs/konarr-cli:latest
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

## Configuration

### Environment Variables

The agent supports configuration via environment variables with `KONARR_AGENT_` prefix:

```bash
# Core settings
export KONARR_INSTANCE="http://konarr.example.com:9000"
export KONARR_AGENT_TOKEN="your-agent-token"
export KONARR_AGENT_PROJECT_ID="project-123"

# Monitoring settings
export KONARR_AGENT_MONITORING=true
export KONARR_AGENT_AUTO_CREATE=true
export KONARR_AGENT_HOST="production-server-01"

# Tool management
export KONARR_AGENT_TOOL="syft"  # or "grype", "trivy"
export KONARR_AGENT_TOOL_AUTO_INSTALL=true
export KONARR_AGENT_TOOL_AUTO_UPDATE=true

# Docker settings
export KONARR_AGENT_DOCKER_SOCKET="/var/run/docker.sock"
```

### Configuration File

Create `konarr.yml` for persistent settings:

```yaml
agent:
  project_id: "my-project"
  create: true           # Auto-create projects
  monitoring: true       # Watch Docker events
  host: "server-01"      # Friendly host name
  
  # Tool configuration
  tool: "syft"          # Primary SBOM tool
  tool_auto_install: true
  tool_auto_update: true
  docker_socket: "/var/run/docker.sock"
```

### CLI Commands

**Agent Mode (Continuous Monitoring):**

```bash
# Monitor with config file
konarr-cli --config ./konarr.yml agent --docker-socket /var/run/docker.sock

# Monitor with environment variables set
konarr-cli agent --docker-socket /var/run/docker.sock

# Monitor specific Docker socket
konarr-cli agent --docker-socket /custom/docker.sock
```

**Scan Mode (One-time Scan):**

```bash
# Scan specific image
konarr-cli scan --image alpine:latest

# Scan with output to file
konarr-cli --config ./konarr.yml scan --image alpine:latest --output scan-results.json
```

**Tool Management:**

```bash
# List available tools
konarr-cli scan --list

# Install specific tool
konarr-cli tools install syft

# Check tool versions
konarr-cli tools list
```

## Scanning Tools

The agent uses external tools for SBOM generation and vulnerability scanning:

### Supported Tools

| Tool | Purpose | Auto-Install | Package Managers |
|------|---------|--------------|------------------|
| **Syft** | SBOM Generation | ✅ | NPM, Cargo, Deb, RPM, PyPI, Maven, Go |
| **Grype** | Vulnerability Scanning | ✅ | All Syft-supported formats |
| **Trivy** | Security Scanning | ✅ | Multi-format vulnerability detection |

### Tool Installation

The agent can automatically install tools:

```bash
# Enable auto-install (default in container images)
export KONARR_AGENT_TOOL_AUTO_INSTALL=true

# Manual tool installation
konarr-cli tools install syft
konarr-cli tools install grype  
konarr-cli tools install trivy
```

**Tool Storage Locations:**

- Container: `/usr/local/toolcache/`
- Host install: `~/.local/bin/` or `/usr/local/bin/`
- Custom: Set via `KONARR_AGENT_TOOLCACHE_PATH`

### Tool Configuration

```yaml
# Custom tool settings
agent:
  tool: "syft"                                    # Primary tool
  tool_auto_install: true                         # Auto-install missing tools
  tool_auto_update: false                         # Auto-update tools
  toolcache_path: "/usr/local/toolcache"         # Tool storage location
```

## Project Management

### Project Creation

The agent can automatically create projects or upload to existing ones:

```bash
# Auto-create project (default behavior)
export KONARR_AGENT_AUTO_CREATE=true

# Use existing project ID
export KONARR_AGENT_PROJECT_ID="existing-project-123"
```

**Project Naming Convention:**

- Docker Compose: `{prefix}/{container_name}`
- Labeled containers: `{prefix}/{image-title}`
- Default: Container name or image name

### Container Filtering

The agent automatically monitors containers but can be configured to filter:

```yaml
# Example filtering (implementation-dependent)
agent:
  monitoring: true
  filters:
    exclude_labels:
      - "konarr.ignore=true"
    include_only:
      - "environment=production"
```

## Docker Compose Integration

For container monitoring via Docker Compose, see our [Agent Docker Compose guide](02-agent-docker-compose.md).

Example `docker-compose.yml` service:

```yaml
services:
  konarr-agent:
    image: ghcr.io/42bytelabs/konarr-agent:latest
    container_name: konarr-agent
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - KONARR_INSTANCE=http://konarr-server:9000
      - KONARR_AGENT_TOKEN=${KONARR_AGENT_TOKEN}
      - KONARR_AGENT_MONITORING=true
      - KONARR_AGENT_AUTO_CREATE=true
```

## Troubleshooting

### Common Issues

**Agent Authentication Failed:**

```bash
# Verify token
echo $KONARR_AGENT_TOKEN

# Test server connection
curl -H "Authorization: Bearer $KONARR_AGENT_TOKEN" \
  http://your-server:9000/api/health
```

**Tool Installation Issues:**

```bash
# Check tool availability
konarr-cli tools list

# Manual tool install
konarr-cli tools install syft

# Check tool cache
ls -la /usr/local/toolcache/
```

**Docker Socket Issues:**

```bash
# Verify Docker socket access
docker ps

# Check socket permissions
ls -la /var/run/docker.sock
```

### Monitoring Agent Status

```bash
# Container logs
docker logs -f konarr-agent

# Agent health (if running as daemon)
konarr-cli agent status

# Server-side agent status
curl http://your-server:9000/api/agents
```

---

**Next Steps**: Configure monitoring and view results in the [Konarr web interface](03-configuration.md#web-ui-usage).
