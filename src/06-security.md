# Security

This page describes Konarr's security model, threat considerations, and comprehensive recommendations for secure production deployments.

## Overview

Konarr handles sensitive supply chain data including:

- Software Bill of Materials (SBOMs) for container images
- Vulnerability scan results and security alerts
- Container metadata and deployment information
- Agent authentication credentials

A comprehensive security approach is essential for protecting this data and maintaining system integrity.

## Authentication and Authorization

### Agent Token Management

Konarr uses a simple but effective token-based authentication model for agents:

- **Token Generation**: The server automatically generates a secure agent token (`agent.key`) on first startup, stored in ServerSettings
- **Token Usage**: Agents authenticate using this token as a Bearer token in the `Authorization` header
- **Token Validation**: The server validates agent requests using a guard system with performance caching and database fallback
- **Single Token Model**: Currently, all agents share a single token for simplicity

#### Best Practices for Agent Tokens

- **Treat as Secret**: Never commit tokens to version control or expose in logs
- **Secure Storage**: Store tokens in secure credential management systems
- **Limited Exposure**: Only provide tokens to authorized agent deployments
- **Regular Rotation**: Implement a token rotation schedule (recommended: quarterly)
- **Environment Variables**: Use environment variables for token distribution, not configuration files

#### Token Rotation Procedure

```bash
# 1. Generate new token (requires server restart or admin API when available)
# Currently requires database update - this will be improved in future versions

# 2. Update all agent deployments with new token
# For Docker environments:
docker service update --env-add KONARR_AGENT_TOKEN="new-token-here" konarr-agent

# 3. Verify all agents are connecting successfully
# Check server logs for authentication failures

# 4. Remove old token references from configuration systems
```

### Web UI Authentication

- **Session-Based**: Web interface uses session-based authentication
- **Admin Access**: Server settings and sensitive operations require admin privileges
- **Session Security**: Sessions are secured with appropriate timeout settings

## Transport Security

### TLS Configuration

**Always use HTTPS in production** - Konarr transmits sensitive vulnerability and SBOM data that must be encrypted in transit.

#### Frontend URL Configuration

Configure the server's frontend URL to ensure secure redirects and callbacks:

```yaml
# konarr.yml
server:
  frontend:
    url: "https://konarr.example.com"
```

### Certificate Management

- **Automated Renewal**: Use Let's Encrypt with automated renewal (certbot, acme.sh)
- **Certificate Monitoring**: Monitor certificate expiration dates
- **Backup Certificates**: Maintain secure backups of certificates and keys

## Runtime Security

### Container Security

#### Docker Socket Access Risks

**⚠️ Critical Security Consideration**: Mounting the Docker socket (`/var/run/docker.sock`) grants significant privileges:

- **Container Creation**: Ability to create privileged containers
- **Host Access**: Access to host filesystem through volume mounts
- **Privilege Escalation**: Potential for privilege escalation attacks
- **Container Inspection**: Access to all running containers and their metadata

#### Security Mitigations

1. **Trusted Hosts Only**: Only run agents on trusted, dedicated hosts
2. **Read-Only Mounts**: Use `:ro` flag when possible: `/var/run/docker.sock:/var/run/docker.sock:ro`
3. **Dedicated Agent Hosts**: Consider dedicated hosts for agent containers
4. **Network Segmentation**: Isolate agent hosts in secure network segments
5. **Host Monitoring**: Monitor host systems for unusual container activity
6. **Alternative Runtimes**: Consider container runtimes with safer introspection APIs

#### Container Image Security

```dockerfile
# Use minimal base images
FROM alpine:3.19

# Run as non-root user
RUN adduser -D -s /bin/sh konarr
USER konarr

# Minimal filesystem
COPY --from=builder /app/konarr-cli /usr/local/bin/
```

### Tool Installation Security

The agent can automatically install security scanning tools (Syft, Grype, Trivy):

#### Supply Chain Security

- **Tool Verification**: Verify tool signatures and checksums when available
- **Controlled Environments**: For strict environments, pre-install approved tool versions
- **Disable Auto-Install**: Set `agent.tool_auto_install: false` and manage tools manually
- **Tool Isolation**: Consider running tools in isolated environments

```yaml
# Secure agent configuration
agent:
  tool_auto_install: false  # Disable automatic tool installation
  toolcache_path: "/usr/local/toolcache"  # Pre-installed tool location
```

## Data Security

### SBOM and Vulnerability Data Protection

SBOM and vulnerability data contains sensitive information about your infrastructure:

#### Access Control

- **API Authentication**: All API endpoints require proper authentication
- **Project Isolation**: Implement project-based access controls
- **Data Classification**: Classify SBOM data according to organizational policies

#### Data Retention

```yaml
# Example retention policy configuration (implementation-dependent)
data:
  retention:
    snapshots: "90d"      # Keep snapshots for 90 days
    vulnerabilities: "1y"  # Keep vulnerability data for 1 year
    logs: "30d"           # Keep logs for 30 days
```

#### Data Encryption

- **At Rest**: Consider encrypting the SQLite database file
- **In Transit**: Always use HTTPS for API communications
- **Backups**: Encrypt database backups

### Database Security

#### File Permissions

```bash
# Secure database file permissions
chmod 600 /data/konarr.db
chown konarr:konarr /data/konarr.db

# Secure data directory
chmod 700 /data
chown konarr:konarr /data
```

#### Backup Security

```bash
# Encrypted backup example
sqlite3 /data/konarr.db ".backup /tmp/konarr-backup.db"
gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output konarr-backup.db.gpg /tmp/konarr-backup.db
rm /tmp/konarr-backup.db
```

## Network Security

### Firewall Configuration

```bash
# Allow only necessary ports
# Server (typically internal)
ufw allow from 10.0.0.0/8 to any port 9000

# Reverse proxy (public)
ufw allow 80
ufw allow 443

# Agent communication (if direct)
ufw allow from <agent-networks> to any port 9000
```

### Network Segmentation

- **DMZ Deployment**: Deploy web-facing components in DMZ
- **Internal Networks**: Keep agents and database on internal networks
- **VPN Access**: Use VPN for administrative access

## Secrets Management

### Configuration Security

- **Environment Variables**: Use environment variables for secrets, not config files
- **Secrets Managers**: Integrate with HashiCorp Vault, AWS Secrets Manager, etc.
- **File Permissions**: Secure configuration files with appropriate permissions

```bash
# Example environment variable configuration
export KONARR_AGENT_TOKEN="$(vault kv get -field=token secret/konarr/agent)"
export KONARR_DATABASE_ENCRYPTION_KEY="$(vault kv get -field=key secret/konarr/database)"
```

### Kubernetes Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: konarr-agent-token
type: Opaque
data:
  token: <base64-encoded-agent-token>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: konarr-agent
spec:
  template:
    spec:
      containers:
      - name: agent
        image: ghcr.io/42bytelabs/konarr-agent:latest
        env:
        - name: KONARR_AGENT_TOKEN
          valueFrom:
            secretKeyRef:
              name: konarr-agent-token
              key: token
```

## Monitoring and Auditing

### Security Monitoring

#### Log Collection

```yaml
# Example logging configuration
logging:
  level: "info"
  audit: true
  destinations:
    - type: "file"
      path: "/var/log/konarr/audit.log"
    - type: "syslog"
      facility: "auth"
```

#### Metrics to Monitor

- Failed authentication attempts
- Unusual agent activity patterns
- Large data uploads or downloads
- Administrative actions
- System resource usage anomalies

#### Alerting

```bash
# Example alert conditions
# - More than 10 failed authentications in 5 minutes
# - Agent uploading unusually large SBOMs
# - New agents connecting from unknown IP addresses
# - Database size growing rapidly
```

### Compliance and Auditing

#### Audit Trail

- **Authentication Events**: Log all authentication attempts and results
- **Data Access**: Log access to sensitive SBOM and vulnerability data
- **Configuration Changes**: Log all server configuration modifications
- **Agent Activity**: Monitor agent connection patterns and data uploads

#### Compliance Considerations

- **Data Residency**: Consider where SBOM data is stored and processed
- **Access Logging**: Maintain detailed access logs for compliance audits
- **Data Retention**: Implement compliant data retention policies
- **Privacy**: Consider privacy implications of container metadata collection

## Incident Response

### Security Incident Procedures

1. **Detection**: Monitor for security events and anomalies
2. **Containment**: Isolate affected systems and revoke compromised tokens
3. **Investigation**: Analyze logs and determine scope of compromise
4. **Recovery**: Restore systems and implement additional protections
5. **Lessons Learned**: Update security procedures based on incidents

### Token Compromise Response

```bash
# If agent token is compromised:
# 1. Immediately rotate the agent token
# 2. Update all legitimate agents
# 3. Monitor for unauthorized access attempts
# 4. Review recent agent activity for suspicious patterns
```

## Security Checklist

### Deployment Security

- [ ] HTTPS/TLS configured with modern ciphers
- [ ] Security headers implemented (HSTS, CSP, etc.)
- [ ] Agent tokens stored securely (not in code/configs)
- [ ] Database file permissions secured (600)
- [ ] Firewall rules configured for minimal access
- [ ] Regular security updates applied
- [ ] Monitoring and alerting configured
- [ ] Backup encryption implemented
- [ ] Agent hosts properly secured
- [ ] Tool installation policies defined

### Operational Security

- [ ] Regular agent token rotation
- [ ] Security monitoring in place
- [ ] Incident response procedures defined
- [ ] Access controls documented and reviewed
- [ ] Compliance requirements mapped and addressed
- [ ] Security training for operators
- [ ] Regular security assessments conducted

## Additional Resources

- [Reverse Proxy Setup Guide](02-server-reverse-proxy.md) - Detailed TLS configuration
- [Agent Configuration](03-configuration-agent.md) - Secure agent deployment
- [API Documentation](05-api.md) - Authentication and authorization details
- [Troubleshooting](07-troubleshooting.md) - Security-related troubleshooting
