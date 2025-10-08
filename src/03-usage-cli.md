# CLI Usage

This page documents common `konarr-cli` workflows and command-line operations.

## Global Options

### Configuration

| Argument | Description |
|----------|-------------|
| `--config <path>` | Path to `konarr.yml` configuration file |
| `--instance <url>` | Konarr server URL (e.g., `http://your-server:9000`) |
| `--token <agent-token>` | Agent authentication token (or use `KONARR_AGENT_TOKEN` env var) |

### Output Control

| Argument | Description |
|----------|-------------|
| `--verbose` / `-v` | Enable verbose logging for debugging |
| `--quiet` / `-q` | Suppress non-essential output |
| `--output <format>` | Output format: `json`, `yaml`, or `table` (default) |

## Core Commands

### Command Reference

#### Agent Subcommand

| Argument | Description |
|----------|-------------|
| `--docker-socket <path>` | Path to Docker socket for container monitoring (default: `/var/run/docker.sock`) |
| `--monitoring` | Enable container monitoring mode |
| `--project <id>` | Target project ID for snapshots |

#### Scan Subcommand

| Argument | Description |
|----------|-------------|
| `--image <name>` | Container image to scan (e.g., `alpine:latest`) |
| `--path <directory>` | Local directory or file to scan |
| `--output <file>` | Output results to file |
| `--list` | List available security tools |
| `--tool <name>` | Specify scanner tool to use |

#### Upload SBOM Subcommand

| Argument | Description |
|----------|-------------|
| `--input <file>` | Path to SBOM file to upload |
| `--snapshot-id <id>` | Target snapshot ID for upload |

#### Tools Subcommand

| Argument | Description |
|----------|-------------|
| `--tool <name>` | Specific tool to install/test (e.g., `syft`, `grype`) |
| `--all` | Apply operation to all tools |
| `--path <directory>` | Installation path for tools |

### Agent Operations

#### Monitor Mode

Continuously monitor Docker containers for changes:

```bash
konarr-cli agent monitor \
  --instance http://your-server:9000 \
  --token <AGENT_TOKEN> \
  --project <PROJECT_ID>
```

#### Daemon Mode

Run agent as a background service:

```bash
konarr-cli agent daemon \
  --config /etc/konarr/konarr.yml \
  --log-file /var/log/konarr-agent.log
```

### Snapshot Management

#### Create Snapshot

Generate and upload a single SBOM snapshot:

```bash
konarr-cli snapshot create \
  --instance http://your-server:9000 \
  --token <AGENT_TOKEN> \
  --project <PROJECT_ID>
```

#### Container Image Analysis

Analyze specific container images:

```bash
# Remote image
konarr-cli snapshot create \
  --image nginx:1.21 \
  --project <PROJECT_ID>

# Local image with custom scanner
konarr-cli snapshot create \
  --image local/my-app:latest \
  --scanner syft \
  --project <PROJECT_ID>
```

#### File System Analysis

Analyze local directories or files:

```bash
# Analyze current directory
konarr-cli snapshot create \
  --path . \
  --project <PROJECT_ID>

# Analyze specific directory
konarr-cli snapshot create \
  --path /opt/application \
  --project <PROJECT_ID>
```

### Tool Management

#### List Available Tools

Show installed security scanning tools:

```bash
konarr-cli tools list
```

Output example:

```text
Tool     Version    Status      Path
syft     v0.96.0    Installed   /usr/local/bin/syft
grype    v0.74.0    Installed   /usr/local/bin/grype
trivy    v0.48.0    Missing     -
```

#### Install Tools

Install missing security tools:

```bash
# Install specific tool
konarr-cli tools install --tool syft

# Install all missing tools
konarr-cli tools install --all

# Install to custom path
konarr-cli tools install --tool grype --path /usr/local/toolcache
```

#### Check Tool Versions

Verify tool versions and compatibility:

```bash
konarr-cli tools version
```

### Project Management

#### List Projects

Display available projects:

```bash
konarr-cli projects list \
  --instance http://your-server:9000 \
  --token <AGENT_TOKEN>
```

#### Create Project

Create a new project:

```bash
konarr-cli projects create \
  --name "my-application" \
  --type container \
  --description "Production web application"
```

## Advanced Usage

### Configuration File

Create `/etc/konarr/konarr.yml`:

```yaml
instance: https://konarr.company.com
agent:
  token: your-secure-token
  project_id: 123
  monitoring: true
  tool_auto_install: true
  toolcache_path: /usr/local/toolcache
  host: production-server-01
  
tools:
  syft:
    version: "v0.96.0"
    path: /usr/local/bin/syft
  grype:
    version: "v0.74.0"
    path: /usr/local/bin/grype
```

Run with configuration:

```bash
konarr-cli --config /etc/konarr/konarr.yml agent monitor
```

### Environment Variables

Set defaults via environment:

```bash
export KONARR_INSTANCE=https://konarr.company.com
export KONARR_AGENT_TOKEN=your-secure-token
export KONARR_AGENT_PROJECT_ID=123
export KONARR_AGENT_MONITORING=true
export KONARR_VERBOSE=true

# Run with environment config
konarr-cli agent monitor
```

### CI/CD Integration

Use in continuous integration pipelines:

```bash
# Build-time analysis
konarr-cli snapshot create \
  --image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA \
  --project $KONARR_PROJECT_ID \
  --fail-on-critical \
  --output json > security-report.json

# Check exit code
if [ $? -ne 0 ]; then
  echo "Critical vulnerabilities found, failing build"
  exit 1
fi
```

### Security Scanning Options

Configure vulnerability scanning behavior:

```bash
# Fail on high/critical vulnerabilities
konarr-cli snapshot create \
  --project <PROJECT_ID> \
  --fail-on-critical \
  --fail-on-high

# Custom severity threshold
konarr-cli snapshot create \
  --project <PROJECT_ID> \
  --max-severity medium

# Skip vulnerability scanning
konarr-cli snapshot create \
  --project <PROJECT_ID> \
  --skip-vulnerability-scan
```

## Troubleshooting

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
konarr-cli --verbose agent monitor
```

### Connection Testing

Test server connectivity:

```bash
konarr-cli health \
  --instance http://your-server:9000
```

### Tool Verification

Verify scanner tools are working:

```bash
konarr-cli tools test --tool syft
konarr-cli tools test --all
```

### Log Analysis

Check agent logs for issues:

```bash
# View recent logs
journalctl -u konarr-agent -f

# Container logs
docker logs -f konarr-agent
```

The agent watches container lifecycle events (when configured) and uploads snapshots automatically. Use `--config` to provide persistent configuration.

## Tooling and debugging

- To list available scanner tools and their paths:

```bash
konarr-cli tools list
```

- Enable verbose logging for troubleshooting (check `konarr-cli --help` for a `--verbose` or `-v` flag).

If you'd like, I can expand this into a full reference for all `konarr-cli` flags and subcommands by parsing the CLI code or the help output.
