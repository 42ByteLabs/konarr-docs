# Docker Compose for Agent

This document shows how to run the Konarr Agent via Docker Compose — useful for running a long-lived agent that monitors a host and uploads snapshots.

## docker-compose example (monitoring host Docker)

Save as `docker-compose-agent.yml` and run from the host you want to monitor.

```yaml
version: '3.8'
services:
  konarr-agent:
    image: ghcr.io/42byteLabs/konarr-agent:latest
    container_name: konarr-agent
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - KONARR_INSTANCE=http://your-server:9000
      - KONARR_AGENT_TOKEN=<AGENT_TOKEN>
      - KONARR_AGENT_MONITORING=true
      - KONARR_AGENT_TOOL_AUTO_INSTALL=true
```

Notes and security

- The compose example mounts the Docker socket as read-only. Even read-only mounts may expose sensitive control; follow the security guidance in `02-agent.md` before using this in production.
- Use a secrets manager (or Docker secrets) to provide the agent token in production rather than hard-coding it in the compose file.

## Run

```bash
docker compose -f docker-compose-agent.yml up -d
```

## Upgrading

```bash
docker compose -f docker-compose-agent.yml pull konarr-agent
docker compose -f docker-compose-agent.yml up -d --no-deps --build konarr-agent
```

---

**See Also:**

- [Kubernetes Deployment](./02-server-kubernetes.md) - Deploy agents across a Kubernetes cluster
- [Agent Configuration](./03-configuration-agent.md) - Detailed agent configuration options
