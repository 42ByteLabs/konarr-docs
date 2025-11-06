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

### Quick Configuration

The agent requires minimal configuration to get started:

**Environment Variables:**

```bash
# Required settings
export KONARR_INSTANCE="http://konarr.example.com:9000"
export KONARR_AGENT_TOKEN="your-agent-token"

# Optional - enable monitoring mode
export KONARR_AGENT_MONITORING=true
export KONARR_AGENT_AUTO_CREATE=true
```

**Configuration File (`konarr.yml`):**

```yaml
agent:
  project_id: "my-project"
  create: true           # Auto-create projects
  monitoring: true       # Watch Docker events
  tool: "syft"          # Primary SBOM tool
  tool_auto_install: true
```

For comprehensive configuration options, security settings, and production deployment examples, see [Agent Configuration Details](03-configuration-agent.md).

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

The agent uses external scanning tools for SBOM generation and vulnerability detection. Three tools are supported:

- **[Syft](https://github.com/anchore/syft)** - Primary SBOM generation tool
- **[Grype](https://github.com/anchore/grype)** - Vulnerability scanning
- **[Trivy](https://github.com/aquasecurity/trivy)** - Comprehensive security scanning

The agent can automatically install these tools when needed:

```bash
# Enable auto-install (default in container images)
export KONARR_AGENT_TOOL_AUTO_INSTALL=true

# Or manually install specific tools
konarr-cli tools install syft
```

For detailed information about each tool, installation options, and configuration, see [Scanning Tools](03-tools.md).

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
