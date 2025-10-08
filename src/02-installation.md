# Installation and Setup

This section provides multiple installation methods for Konarr. Choose the method that best fits your environment:

- **Quick Start**: One-line installer script
- **Docker Compose**: Full stack with server and agent  
- **Individual Components**: Install server and agent separately
- **From Source**: Build from the GitHub repository

## Quick Start (Recommended)

The fastest way to get Konarr running is with Docker:

```bash
# Run Konarr server
docker run -d \
  --name konarr \
  -p 9000:9000 \
  -v ./data:/data \
  -v ./config:/config \
  ghcr.io/42bytelabs/konarr:latest
```

This will start the Konarr server with:

- Web interface accessible at `http://localhost:9000`
- Data persistence in `./data` directory
- Optional configuration in `./config/konarr.yml`

## Docker Compose Setup

For a complete development environment with both server and frontend:

```bash
# Clone repository
git clone https://github.com/42ByteLabs/konarr.git && cd konarr
git submodule update --init --recursive

# Start services
docker-compose up -d
```

This provides:

- Konarr server on port 9000
- Development setup with both server and frontend
- Persistent data volumes
- Automatic service management

## Component Installation

For detailed setup of individual components:

- **Server**: [Server Installation Guide](02-server.md) - API, web UI, and data storage
- **Agent**: [Agent Installation Guide](02-agent.md) - Container monitoring and SBOM generation

## Prerequisites

**For Container Deployment:**

- Docker (v20.10+) or Podman (v3.0+)
- Docker Compose (optional, for multi-container setup)

**For Source Installation:**

- Rust and Cargo (latest stable)
- Node.js and npm (for frontend build)
- Git (for cloning repository)

**System Requirements:**

- **Minimum**: 256MB RAM, 1GB disk space
- **Recommended**: 512MB+ RAM, 5GB+ disk space (for SBOM storage)

## Quick Workflow

1. **Start the server** (port 9000 by default)
2. **Access the web UI** at `http://localhost:9000`
3. **Retrieve the agent token** from server settings or database
4. **Deploy agents** on hosts you want to monitor
5. **Create projects** to organize your container monitoring
6. **View SBOMs and vulnerabilities** in the [web interface](04-usage-web.md)

## Default Ports and Paths

- **Server Port**: 9000 (HTTP)
- **Data Directory**: `./data` (contains SQLite database)
- **Config Directory**: `./config` (contains `konarr.yml`)
- **Database**: `./data/konarr.db` (SQLite)
- **Agent Token**: Stored in server settings as `agent.key`

---

## Verifying and Troubleshooting

1. Start the server and open the UI: <http://localhost:9000> (or configured host).
2. Start the agent with the correct instance URL, token and a project id or auto-create enabled.
3. Confirm snapshots appear in the project view and the server shows the agent as authenticated.

Common troubleshooting

- Agent authentication failures: double-check `KONARR_AGENT_TOKEN` value and ensure the server `agent.key` matches.
- Missing scanner binaries: either enable `agent.tool_auto_install` or install syft/grype/trivy on the host/container and make sure they are on PATH or in `/usr/local/toolcache`.
- Frontend not served when running server from source: build frontend (`client/`) and point server `frontend` config to the `dist` directory.

---

Need more?

If you'd like, I can also:

- Add a ready-to-use `docker-compose.yml` snippet to the server page.
- Add an API example to find/create a Project ID.
- Add example `konarr.yml` snippets for common production deployments.
