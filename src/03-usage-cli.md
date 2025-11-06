# CLI Usage

This page documents common `konarr-cli` workflows and command-line operations.

**CLI Implementation**: The CLI is implemented in [cli/src/main.rs](https://github.com/42ByteLabs/konarr/blob/main/cli/src/main.rs) with command handlers in [cli/src/cli](https://github.com/42ByteLabs/konarr/tree/main/cli/src/cli). Agent operations are in [cli/src/cli/agent.rs](https://github.com/42ByteLabs/konarr/blob/main/cli/src/cli/agent.rs).

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

#### Monitor Containers

Run the agent in monitoring mode to continuously watch Docker containers:

```bash
konarr-cli agent \
  --instance http://your-server:9000 \
  --token <AGENT_TOKEN> \
  --docker-socket /var/run/docker.sock
```

This will:

- Monitor Docker socket for container events
- Auto-create projects when `agent.create` is enabled
- Generate SBOMs when containers start or change
- Upload snapshots to the server

#### Scan Specific Images

Scan and analyze a specific container image:

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
# Scan container image
konarr-cli scan --image nginx:latest

# Save output to file
konarr-cli scan --image alpine:latest --output sbom.json
```

### Tool Management

#### List Available Tools

Show which security scanning tools are available:

```bash
konarr-cli scan --list
```

This will display installed tools and their versions. The agent can automatically install missing tools when `agent.tool_auto_install` is enabled (see [Scanning Tools](03-tools.md)).

### User Management

#### Create or Reset User Password

The `database user` command allows you to create new users or reset passwords for existing users. This is an interactive command that prompts for user information:

```bash
konarr-cli database user
```

The command will prompt you for:

1. **Username**: The username for the user account
2. **Password**: The new password (hidden input)
3. **Role**: User role - either `Admin` or `User`

**Behavior:**

- If the username already exists, the command will update the user's password and role
- If the username doesn't exist, a new user account will be created
- This command is useful for password recovery when users forget their credentials

**Example session:**

```bash
$ konarr-cli database user
Username: admin
Password: ********
Role: 
> Admin
  User
User updated successfully
```

**Non-interactive usage:**

For automated setups or scripts, you can provide the database path:

```bash
konarr-cli --database-url /data/konarr.db database user
```

**Common use cases:**

- **Initial admin account creation**: Set up the first admin user after installation
- **Password reset**: Reset a forgotten user password
- **Role update**: Change a user's role from User to Admin or vice versa
- **Emergency access**: Regain access when locked out of the web interface

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
konarr-cli --config /etc/konarr/konarr.yml agent --docker-socket /var/run/docker.sock
```

### Environment Variables

Set defaults via environment:

```bash
export KONARR_INSTANCE=https://konarr.company.com
export KONARR_AGENT_TOKEN=your-secure-token
export KONARR_AGENT_MONITORING=true

# Run with environment config
konarr-cli agent --docker-socket /var/run/docker.sock
```

### CI/CD Integration

Use in continuous integration pipelines to scan container images:

```bash
# Scan container image in CI pipeline
konarr-cli scan \
  --image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA \
  --output security-report.json

# Upload SBOM to Konarr server
konarr-cli upload-sbom \
  --input security-report.json
```

## Troubleshooting

### Debug Mode

Enable debug logging for troubleshooting:

```bash
konarr-cli --debug agent --docker-socket /var/run/docker.sock
```

### Tool Verification

Check which scanner tools are available:

```bash
konarr-cli scan --list
```

### Log Analysis

Check agent logs for issues:

```bash
# Container logs
docker logs -f konarr-agent
```

### Getting Help

For complete CLI reference, use the built-in help:

```bash
konarr-cli --help
konarr-cli agent --help
konarr-cli scan --help
konarr-cli upload-sbom --help
konarr-cli database --help
```
