# Agent Configuration Overview

The Konarr Agent (`konarr-cli`) is a powerful Rust-based command-line tool that monitors containers, generates Software Bill of Materials (SBOMs), and uploads security data to the Konarr server. This section provides comprehensive guidance for configuring and deploying agents in various environments.

**Implementation**: The agent CLI is implemented in [cli/src](https://github.com/42ByteLabs/konarr/tree/main/cli/src) with agent-specific functionality in [cli/src/cli/agent.rs](https://github.com/42ByteLabs/konarr/blob/main/cli/src/cli/agent.rs). Configuration is managed through [src/utils/config/client.rs](https://github.com/42ByteLabs/konarr/blob/main/src/utils/config/client.rs).

---

## Agent Overview

The Konarr Agent serves as the data collection component of the Konarr ecosystem, responsible for:

- **Container Monitoring**: Continuous monitoring of Docker containers and their states
- **SBOM Generation**: Creating comprehensive Software Bill of Materials using industry-standard tools
- **Vulnerability Scanning**: Integration with security scanners like Syft, Grype, and Trivy  
- **Project Management**: Automatic creation and organization of projects based on container metadata
- **Real-time Updates**: Live detection of container changes and automated snapshot creation

### Key Features

- **Multi-tool Support**: Works with Syft, Grype, Trivy, and other security scanning tools
- **Auto-discovery**: Automatically detects and monitors running containers
- **Flexible Deployment**: Runs as Docker container, standalone binary, or system service
- **Smart Snapshots**: Creates new snapshots only when changes are detected
- **Metadata Enrichment**: Automatically adds container and system metadata to snapshots

---

## Core Capabilities

### Container Discovery and Monitoring

The agent automatically discovers running containers and organizes them into projects:

- **Docker Integration**: Direct integration with Docker daemon via socket
- **Container Metadata**: Extracts labels, environment variables, and runtime information
- **Project Hierarchy**: Supports parent-child project relationships for complex deployments
- **State Tracking**: Monitors container lifecycle events and state changes

### SBOM Generation and Management

- **Multiple Formats**: Supports CycloneDX, SPDX, and other SBOM standards
- **Tool Integration**: Seamlessly integrates with popular scanning tools
- **Dependency Analysis**: Comprehensive dependency tracking and version management
- **Incremental Updates**: Only generates new SBOMs when container contents change

### Security and Vulnerability Management

- **Real-time Scanning**: Continuous vulnerability assessment of monitored containers
- **Multi-source Data**: Aggregates vulnerability data from multiple security databases
- **Risk Assessment**: Provides severity analysis and impact evaluation
- **Alert Integration**: Automatically creates security alerts for discovered vulnerabilities

---

## Operation Modes

### One-shot Scanning

Execute a single scan operation and exit:

```bash
# Scan specific container image
konarr-cli scan --image nginx:latest

# Upload existing SBOM
konarr-cli upload-sbom --input sbom.json --snapshot-id 123
```

### Monitoring Mode

Continuous monitoring with Docker socket access:

```bash
# Monitor containers with Docker socket
konarr-cli agent --docker-socket /var/run/docker.sock

# Monitor with project ID specified
konarr-cli --config konarr.yml --project-id 456 agent --docker-socket /var/run/docker.sock
```

### Agent as Service

Background service operation:

```bash
# Run agent with configuration file
konarr-cli --config /etc/konarr/konarr.yml agent --docker-socket /var/run/docker.sock

# Docker container with volume persistence
docker run -d --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /etc/konarr:/config \
  ghcr.io/42bytelabs/konarr-agent:latest
```

---

## Configuration Approaches

### Environment Variables

Quick setup using environment variables:

```bash
export KONARR_INSTANCE="https://konarr.example.com"
export KONARR_AGENT_TOKEN="kagent_..."
export KONARR_AGENT_MONITORING=true
export KONARR_AGENT_AUTO_CREATE=true
export KONARR_AGENT_HOST="production-server-01"
```

### Configuration File

Structured configuration using YAML:

```yaml
# konarr.yml
instance: "https://konarr.example.com"

agent:
  token: "kagent_..."
  monitoring: true
  create: true
  host: "production-server-01"
  project_id: 123
  
  # Tool configuration
  tool_auto_install: true
  tool_auto_update: true
  toolcache_path: "/usr/local/toolcache"
```

### Command Line Arguments

Direct configuration via CLI arguments:

```bash
konarr-cli \
  --instance https://konarr.example.com \
  --agent-token kagent_... \
  --monitoring \
  --auto-create \
  agent
```

---

## Quick Start Examples

### Basic Container Monitoring

```bash
# Docker container with minimal configuration
docker run -d \
  --name konarr-agent \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e KONARR_INSTANCE="http://your-server:9000" \
  -e KONARR_AGENT_TOKEN="<AGENT_TOKEN>" \
  -e KONARR_AGENT_MONITORING=true \
  -e KONARR_AGENT_AUTO_CREATE=true \
  ghcr.io/42bytelabs/konarr-agent:latest
```

### Production Deployment

```yaml
# docker-compose.yml
version: '3.8'
services:
  konarr-agent:
    image: ghcr.io/42bytelabs/konarr-agent:latest
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./config:/config
    environment:
      - KONARR_INSTANCE=https://konarr.example.com
      - KONARR_AGENT_TOKEN_FILE=/config/agent.token
      - KONARR_AGENT_MONITORING=true
      - KONARR_AGENT_HOST=production-cluster-01
    networks:
      - konarr-network
```

### Binary Installation

```bash
# Install via Cargo
cargo install konarr-cli

# Configure and run
konarr-cli --config /etc/konarr/konarr.yml agent --docker-socket /var/run/docker.sock
```

---

## Agent Management

### Project Organization

- **Auto-creation**: Agents can automatically create projects based on container metadata
- **Hierarchical Structure**: Support for parent-child project relationships
- **Naming Conventions**: Configurable project naming based on container labels or composition
- **Metadata Inheritance**: Child projects inherit metadata from parent projects

### Tool Management

- **Auto-installation**: Automatic download and installation of required scanning tools
- **Version Management**: Automatic updates to latest tool versions when configured
- **Custom Tools**: Support for custom scanning tools and configurations
- **Tool Caching**: Shared tool cache to reduce storage requirements

### Security Considerations

- **Token Management**: Secure handling of authentication tokens
- **Network Security**: TLS/SSL support for secure communication with server
- **Container Security**: Minimal container footprint with security best practices
- **Access Control**: Granular permissions for different agent operations

---

## Documentation Structure

This agent configuration section is organized into focused guides for different aspects:

### **[CLI Usage Guide](03-usage-cli.md)**

Comprehensive command-line interface documentation covering:

- All available commands and options
- Common workflows and use cases
- Debugging and troubleshooting commands
- Integration with CI/CD pipelines

### **[Agent Configuration Details](03-configuration-agent.md)**

Complete configuration reference including:

- All configuration options and their effects
- Environment variable mappings
- Production deployment configurations
- Security and authentication settings

---

## Next Steps

Choose the appropriate guide based on your needs:

1. **[CLI Usage](03-usage-cli.md)** - Learn command-line operations and workflows
2. **[Agent Configuration](03-configuration-agent.md)** - Configure agents for your environment
3. **[Server Configuration](03-server.md)** - Set up the Konarr server to work with agents
4. **[Web Interface](04-usage-web.md)** - Monitor and manage agents through the web interface

For installation instructions, see the [Agent Installation Guide](02-agent.md).

For troubleshooting, see the [Troubleshooting Guide](07-troubleshooting.md).
