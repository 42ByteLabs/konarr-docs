# Troubleshooting

This guide helps resolve common issues with Konarr server and agent deployments.

## Server Issues

### Server Won't Start

**Problem**: Server fails to start or exits immediately.

**Solutions**:

1. Check database permissions:

   ```bash
   # Ensure data directory is writable
   chmod 755 /data
   ls -la /data/konarr.db
   ```

2. Verify configuration:

   ```bash
   # Test configuration file syntax
   cargo run -p konarr-server -- --config konarr.yml --debug
   ```

3. Check port availability:

   ```bash
   # Verify port 9000 is available
   netstat -tulpn | grep :9000
   ```

4. Review server logs:

   ```bash
   # Docker container logs
   docker logs konarr-server

   # Systemd service logs
   journalctl -u konarr-server -f
   ```

### Database Issues

**Problem**: Database corruption or migration failures.

**Solutions**:

1. Backup and recover database:

   ```bash
   # Backup current database
   cp /data/konarr.db /data/konarr.db.backup

   # Check database integrity
   sqlite3 /data/konarr.db "PRAGMA integrity_check;"
   ```

2. Reset database (data loss):

   ```bash
   # Stop server, remove database, restart
   rm /data/konarr.db
   # Server will recreate database on next start
   ```

### Web UI Not Loading

**Problem**: UI shows blank page or loading errors.

**Solutions**:

1. Check frontend configuration:

   ```yaml
   # konarr.yml
   server:
     frontend:
       url: "https://konarr.example.com"
   ```

2. Verify reverse proxy (if used):

   ```nginx
   # nginx example
   location / {
     proxy_pass http://localhost:9000;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
   }
   ```

3. Clear browser cache and cookies

## Agent Issues

### Authentication Failures

**Problem**: Agent cannot authenticate with server.

**Error**: `Authentication failed` or `Invalid token`

**Solutions**:

1. Verify agent token:

   ```bash
   # Check server for current token
   curl -s http://localhost:9000/api/health
   
   # Verify agent token matches server
   echo $KONARR_AGENT_TOKEN
   ```

2. Generate new token:

   ```bash
   # Access server admin UI
   # Navigate to Settings > Agent Token
   # Generate new token and update agents
   ```

3. Check token format:

   ```bash
   # Token should be base64-encoded string
   # Verify no extra whitespace or newlines
   echo -n "$KONARR_AGENT_TOKEN" | wc -c
   ```

### Web UI Login Issues

**Problem**: Cannot log in to the web interface or forgot password.

**Solutions**:

1. Reset user password using the CLI:

   ```bash
   # Interactive password reset
   konarr-cli database user
   
   # Follow the prompts:
   # - Enter the username
   # - Enter the new password
   # - Select the role (Admin/User)
   ```

2. Create a new admin user if locked out:

   ```bash
   # Create emergency admin account
   konarr-cli --database-url /data/konarr.db database user
   
   # When prompted:
   # Username: emergency-admin
   # Password: [enter secure password]
   # Role: Admin
   ```

3. For container deployments:

   ```bash
   # Access container and reset password
   docker exec -it konarr-server konarr-cli database user
   
   # Or with volume-mounted database
   konarr-cli --database-url /path/to/konarr.db database user
   ```

**Note**: The `database user` command can both create new users and reset passwords for existing users. See the [CLI Usage Guide](03-usage-cli.md#user-management) for more details.

### Tool Installation Problems

**Problem**: Agent cannot install or find security tools.

**Solutions**:

1. Manual tool installation:

   ```bash
   # Install Syft
   curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

   # Install Grype
   curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

   # Install Trivy
   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
   ```

2. Check tool paths:

   ```bash
   # Verify tools are accessible
   which syft
   which grype
   which trivy

   # Test tool execution
   syft --version
   grype --version
   trivy --version
   ```

3. Configure toolcache path:

   ```yaml
   # konarr.yml
   agent:
     toolcache_path: "/usr/local/toolcache"
     tool_auto_install: true
   ```

### Docker Socket Access

**Problem**: Agent cannot access Docker socket.

**Error**: `Cannot connect to Docker daemon`

**Solutions**:

1. Check Docker socket permissions:

   ```bash
   # Verify socket exists and is accessible
   ls -la /var/run/docker.sock
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

2. Container socket mounting:

   ```bash
   # Ensure socket is properly mounted
   docker run -v /var/run/docker.sock:/var/run/docker.sock \
     ghcr.io/42bytelabs/konarr-agent:latest
   ```

3. Docker daemon status:

   ```bash
   # Check Docker daemon is running
   systemctl status docker
   sudo systemctl start docker
   ```

### Network Connectivity

**Problem**: Agent cannot reach Konarr server.

**Solutions**:

1. Test connectivity:

   ```bash
   # Test server reachability
   curl -v http://konarr-server:9000/api/health
   
   # Check DNS resolution
   nslookup konarr-server
   ```

2. Firewall configuration:

   ```bash
   # Check firewall rules
   sudo ufw status
   sudo firewall-cmd --list-all
   
   # Allow port 9000
   sudo ufw allow 9000
   ```

3. Network configuration:

   ```bash
   # Check network interfaces
   ip addr show
   
   # Test port connectivity
   telnet konarr-server 9000
   ```

## Container Issues

### Image Pull Failures

**Problem**: Cannot pull Konarr container images.

**Solutions**:

1. Check image availability:

   ```bash
   # List available tags
   curl -s https://api.github.com/repos/42ByteLabs/konarr/packages/container/konarr/versions
   
   # Pull specific version
   docker pull ghcr.io/42bytelabs/konarr:v0.4.4
   ```

2. Authentication for private registries:

   ```bash
   # Login to GitHub Container Registry
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

### Container Startup Issues

**Problem**: Containers exit immediately or crash.

**Solutions**:

1. Check container logs:

   ```bash
   # View container logs
   docker logs konarr-server
   docker logs konarr-agent
   
   # Follow logs in real-time
   docker logs -f konarr-server
   ```

2. Verify volume mounts:

   ```bash
   # Check mount points exist and are writable
   ls -la /host/data
   ls -la /host/config
   
   # Fix permissions if needed
   sudo chown -R 1000:1000 /host/data
   ```

3. Resource constraints:

   ```bash
   # Check available resources
   docker stats
   free -h
   df -h
   ```

## Performance Issues

### High Memory Usage

**Problem**: Server or agent consuming excessive memory.

**Solutions**:

1. Monitor memory usage:

   ```bash
   # Check process memory
   ps aux | grep konarr
   
   # Monitor container resources
   docker stats konarr-server
   ```

2. Configure resource limits:

   ```yaml
   # docker-compose.yml
   services:
     konarr:
       deploy:
         resources:
           limits:
             memory: 512M
           reservations:
             memory: 256M
   ```

3. Database optimization:

   ```bash
   # Vacuum SQLite database
   sqlite3 /data/konarr.db "VACUUM;"
   
   # Check database size
   du -h /data/konarr.db
   ```

### Slow SBOM Generation

**Problem**: Agent takes too long to generate SBOMs.

**Solutions**:

1. Check scanner performance:

   ```bash
   # Test individual tools
   time syft nginx:latest
   time grype nginx:latest
   ```

2. Optimize container caching:

   ```bash
   # Pre-pull base images
   docker pull alpine:latest
   docker pull ubuntu:latest
   
   # Use local registry for faster access
   ```

3. Adjust scanning scope:

   ```yaml
   # konarr.yml - reduce scan scope
   agent:
     scan_config:
       exclude_paths:
         - "/tmp"
         - "/var/cache"
   ```

## Debugging

### Enable Debug Logging

**Server Debug Mode**:

```bash
# Environment variable
export RUST_LOG=debug

# Configuration file
echo "log_level = 'debug'" >> konarr.yml
```

**Agent Debug Mode**:

```bash
# Debug Agent
konarr-cli --debug agent --docker-socket /var/run/docker.sock

# Debug environment
export KONARR_LOG_LEVEL=debug
```

### API Debugging

**Test API Endpoints**:

```bash
# Health check
curl -v http://localhost:9000/api/health

# Authentication test
curl -H "Authorization: Bearer $AGENT_TOKEN" \
     http://localhost:9000/api/projects

# Raw SBOM upload test
curl -X POST \
     -H "Authorization: Bearer $AGENT_TOKEN" \
     -H "Content-Type: application/json" \
     -d @sbom.json \
     http://localhost:9000/api/snapshots
```

### Database Debugging

**Query Database Directly**:

```bash
# Connect to SQLite database
sqlite3 /data/konarr.db

# Common debugging queries
.tables
SELECT COUNT(*) FROM projects;
SELECT COUNT(*) FROM snapshots;
SELECT COUNT(*) FROM components;

# Check recent activity
SELECT * FROM snapshots ORDER BY created_at DESC LIMIT 10;
```

## Configuration Validation and Debugging

### Initial Setup Verification

#### 1. Server Health Check

```bash
# Test server is running and accessible
curl -v http://localhost:9000/api/health

# Expected response:
# HTTP/1.1 200 OK
# {"status":"healthy","version":"x.x.x"}
```

#### 2. Database Verification

```bash
# Check database file exists and is accessible
ls -la /data/konarr.db

# Verify database structure
sqlite3 /data/konarr.db ".tables"

# Check server settings
sqlite3 /data/konarr.db "SELECT name, value FROM server_settings WHERE name LIKE 'agent%';"
```

#### 3. Agent Authentication Test

```bash
# Test agent token authentication
curl -H "Authorization: Bearer ${KONARR_AGENT_TOKEN}" \
     http://localhost:9000/api/projects

# Successful authentication returns project list
```

### Advanced Configuration Troubleshooting

#### Server Startup Problems

**Issue**: Server fails to start or exits immediately

**Solutions**:

1. **Check configuration file syntax**:

   ```bash
   # Validate YAML syntax
   python -c "import yaml; yaml.safe_load(open('konarr.yml'))"
   ```

2. **Verify data directory permissions**:

   ```bash
   # Ensure data directory is writable
   mkdir -p /data
   chmod 755 /data
   chown konarr:konarr /data  # If running as specific user
   ```

3. **Check port availability**:

   ```bash
   # Verify port 9000 is not in use
   netstat -tulpn | grep :9000
   lsof -i :9000
   ```

**Issue**: Frontend not served properly

**Solutions**:

1. **Check frontend path configuration**:

   ```yaml
   server:
     frontend: "/app/dist"  # Ensure path exists and contains built frontend
   ```

2. **Verify frontend files exist**:

   ```bash
   ls -la /app/dist/
   # Should contain: index.html, static/, assets/
   ```

#### Agent Configuration Problems

**Issue**: Agent cannot connect to server

**Solutions**:

1. **Verify server URL configuration**:

   ```bash
   # Test connectivity
   curl -v http://konarr.example.com:9000/api/health
   ```

2. **Check agent token**:

   ```bash
   # Retrieve current agent token from server
   sqlite3 /data/konarr.db "SELECT value FROM server_settings WHERE name='agent.key';"
   ```

3. **Network troubleshooting**:

   ```bash
   # Test DNS resolution
   nslookup konarr.example.com
   
   # Test port connectivity
   telnet konarr.example.com 9000
   ```

**Issue**: Agent tools not found or installation fails

**Solutions**:

1. **Manual tool installation**:

   ```bash
   # Install Syft
   curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
     sh -s -- -b /usr/local/bin
   
   # Install Grype
   curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
     sh -s -- -b /usr/local/bin
   
   # Install Trivy
   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
     sh -s -- -b /usr/local/bin
   ```

2. **Verify tool paths**:

   ```bash
   # Check tools are accessible
   which syft grype trivy
   /usr/local/bin/syft version
   /usr/local/bin/grype version
   /usr/local/bin/trivy version
   ```

3. **Configure custom tool paths**:

   ```yaml
   agent:
     toolcache_path: "/opt/security-tools"
     tool_auto_install: false
   ```

### Performance Optimization

#### Database Performance

```bash
# Analyze database size and performance
sqlite3 /data/konarr.db "PRAGMA integrity_check;"
sqlite3 /data/konarr.db "VACUUM;"
sqlite3 /data/konarr.db "ANALYZE;"

# Check database file size
du -h /data/konarr.db
```

#### Memory and Resource Usage

```bash
# Monitor server resource usage
ps aux | grep konarr-server
htop -p $(pgrep konarr-server)

# Container resource monitoring
docker stats konarr-server konarr-agent
```

### Security Verification

#### SSL/TLS Configuration

```bash
# Test SSL certificate and configuration
openssl s_client -connect konarr.example.com:443 -servername konarr.example.com

# Check certificate expiration
curl -vI https://konarr.example.com 2>&1 | grep -E "(expire|until)"
```

#### Token Security

```bash
# Verify agent token entropy and length
echo $KONARR_AGENT_TOKEN | wc -c  # Should be 43+ characters
echo $KONARR_AGENT_TOKEN | head -c 10  # Should start with "kagent_"
```

### Logging and Debugging

#### Enable Server Debug Logging

**Server debug mode**:

```bash
# Environment variable
export RUST_LOG=debug

# Or configuration file
echo "log_level: debug" >> konarr.yml
```

**Agent debug mode**:

```bash
# CLI flag
konarr-cli --debug agent monitor

# Environment variable
export KONARR_LOG_LEVEL=debug
```

#### Log Analysis

```bash
# Server logs (Docker)
docker logs -f konarr-server

# Agent logs (Docker)
docker logs -f konarr-agent

# System service logs
journalctl -u konarr-server -f
journalctl -u konarr-agent -f
```

### Configuration Testing and Validation

#### Complete Configuration Test

```bash
# Test complete configuration (development)
cargo run -p konarr-server -- --config konarr.yml --debug

# Test agent configuration
konarr-cli --config konarr.yml --debug
```

#### Environment Variable Precedence

```bash
# Check configuration with debug output
konarr-cli --config konarr.yml --debug

# List all environment variables
env | grep KONARR_ | sort
```

## Getting Help

### Log Collection

When seeking support, collect these logs:

```bash
# Server logs
docker logs konarr-server > server.log 2>&1

# Agent logs
docker logs konarr-agent > agent.log 2>&1

# System information
docker info > docker-info.txt
uname -a > system-info.txt
```

### Support Channels

- **GitHub Issues**: <https://github.com/42ByteLabs/konarr/issues>
- **Documentation**: <https://42bytelabs.github.io/konarr-docs/>
- **Community**: GitHub Discussions

### Reporting Bugs

Include in bug reports:

1. Konarr version (`konarr-server --version`)
2. Operating system and version
3. Docker/container runtime version
4. Complete error messages and stack traces
5. Steps to reproduce the issue
6. Configuration files (remove sensitive data)
