# Server Docker Compose

This page provides a ready-to-use Docker Compose example and notes for deploying the Konarr Server in a multi-container environment (eg. web + DB volumes). The example focuses on the official Konarr image and mounting persistent volumes for data and config.

## docker-compose example

Save the following as `docker-compose.yml` in your deployment directory and adjust paths and environment variables as needed:

```yaml
services:
  konarr:
    image: ghcr.io/42bytelabs/konarr:latest
    container_name: konarr
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - ./data:/data
      - ./config:/config
    environment:
      # Use KONARR_ prefixed env vars to configure the server if you prefer env-based config
      - KONARR_DATA_PATH=/data
      - KONARR_CONFIG_PATH=/config/konarr.yml
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9000/api/health || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
```

## Deploy

```bash
# start in detached mode
docker compose up -d
```

### Monitor logs

```bash
# show logs
docker compose logs -f konarr
```

## Volumes and persistent data

- `./data` stores the SQLite database and other runtime state — back this up regularly.
- `./config` stores `konarr.yml` (optional). If you want immutable configuration, mount a read-only config volume and supply environment variables for secrets.

## Backups and migrations

- Backup the `data/konarr.db` file before performing upgrades.
- On first run the server will run migrations; ensure your backup is taken before major version upgrades.

## Upgrading the image

1. Pull the new image: `docker compose pull konarr`
2. Restart the service: `docker compose up -d --no-deps --build konarr`
3. Monitor logs for migrations: `docker compose logs -f konarr`

## Notes

- The server listens on port 9000 by default.
- Use a reverse proxy or load balancer in front of the service for TLS termination in production.
- For security, protect the `config` and `data` directories and do not expose the database file to untrusted users.

---

**See Also:**

- [Reverse Proxy Setup](./02-server-reverse-proxy.md) - Nginx and other reverse proxy examples with TLS
- [Security](./06-security.md) - Security best practices and recommendations
