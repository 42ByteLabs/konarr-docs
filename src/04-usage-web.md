# Web Interface

This guide covers how to use the Konarr web interface to monitor your containers, view SBOMs, manage projects, and track security vulnerabilities.

## Accessing the Web Interface

### Basic Access

Open the server URL in your browser (default port 9000):

```text
http://<konarr-host>:9000
```

**Examples:**

- Local development: `http://localhost:9000`
- Network deployment: `http://your-server-ip:9000`
- Custom domain: `https://konarr.example.com`

### Behind Reverse Proxy

If the server is behind a reverse proxy or load balancer, use the external HTTPS URL configured in `server.frontend.url`.

For reverse proxy setup, see the [Reverse Proxy Setup Guide](02-server-reverse-proxy.md).

### Authentication

The web interface uses session-based authentication:

1. **Session Authentication** - Login through the web interface to obtain session cookies
2. **Admin Access** - Required for server settings, user management, and advanced features
3. **User Access** - Standard access for viewing projects, snapshots, and alerts

---

## Main Interface Areas

The Konarr web interface is organized into several main sections:

### 📁 Projects

- **Purpose**: Logical groups representing hosts, applications, or container clusters
- **Contents**: Each project contains snapshots, SBOMs, and security data
- **Features**:
  - Project hierarchy (parent/child relationships)
  - Project types: Containers, Groups, Applications, Servers
  - Status indicators (online/offline)
  - Search and filtering capabilities

### 📸 Snapshots

- **Purpose**: Captured states of containers or systems at specific points in time
- **Contents**: SBOM data, dependency information, vulnerability scan results
- **Features**:
  - Click snapshots to view detailed SBOM and vulnerability summaries
  - Comparison between different snapshot versions
  - Metadata including scan tools used, timestamps, and container information

### 🚨 Alerts

- **Purpose**: Security vulnerability alerts generated from scans
- **Contents**: Vulnerability details, severity levels, affected components
- **Features**:
  - Severity filtering (Critical, High, Medium, Low)
  - Alert state management (Vulnerable, Acknowledged, Secure)
  - Search and filtering by CVE, component, or description
  - Bulk operations for alert management

### 👤 User Profile

- **Purpose**: Personal account management and settings
- **Contents**:
  - View account details (username, role, status)
  - Password management with strength validation
  - Active session management
  - Account creation date and last login information
- **Access**: Available to all authenticated users

### ⚙️ Settings / Admin

- **Purpose**: Server-level configuration and administration (admin-only)
- **Contents**:
  - User and token management with enhanced UI
  - Agent authentication settings
  - Server configuration
  - System health and statistics
- **Access**: Requires admin privileges

---

## User Profile Management

### Accessing Your Profile

Navigate to your profile page from the navigation menu:

- **Location**: User menu in the top navigation bar
- **Access**: Available to all authenticated users
- **URL**: `/profile`

### Profile Information

View and manage your account details:

- **Username**: Your unique account identifier
- **Role**: Your assigned role (Admin or User)
- **Status**: Account state (Active, Inactive, Suspended)
- **Created At**: Account creation timestamp
- **Last Login**: Most recent login time
- **Avatar**: Profile picture (if configured)

### Password Management

Change your password securely through the profile page:

1. **Enter Current Password**: Authenticate the change request
2. **Set New Password**: Must be at least 8 characters
3. **Confirm Password**: Verify new password entry
4. **Password Strength**: Real-time validation shows password strength
5. **Submit**: Update your password

**Security Notes**:

- Passwords must be at least 8 characters long
- Strong passwords are recommended (mix of letters, numbers, symbols)
- Changing password will not log out active sessions immediately

### Session Management

View and monitor your active sessions:

- **Active Sessions**: List of currently authenticated sessions
- **Session Details**: Login time, device/browser information
- **Session Security**: Review unusual or unexpected sessions

For session management and security, see the [Security Guide](06-security.md).

---

## Projects Management

### Creating Projects

Projects can be created in two ways:

1. **Manual Creation**: Through the web interface (admin required)
2. **Auto-Creation**: Agents can automatically create projects when configured with `agent.create: true`

### Project Types

- **Container**: Individual container projects
- **Group**: Collections of related projects (e.g., microservices)
- **Application**: Application-specific projects
- **Server**: Host-level projects

### Project Features

- **Hierarchy**: Projects can have parent-child relationships for organization
- **Search**: Use the search/filter box to find specific projects by name, tag, or hostname
- **Status**: Visual indicators show project health and last update status
- **Statistics**: View snapshot counts, vulnerability summaries, and last scan times
- **Setup Workflow**: Streamlined agent deployment instructions for new projects

### Project Setup Tab

The Setup tab provides streamlined deployment guidance for configuring agents to monitor your containers and submit SBOMs to Konarr. This page automatically generates ready-to-use commands with pre-configured authentication tokens and project IDs.

**Accessing the Setup Tab:**

1. Navigate to your project from the Projects list
2. Click the "Setup" tab in the project navigation
3. URL pattern: `/projects/{id}/setup`

The Setup tab offers three deployment methods:

#### Docker Deployment

The Docker section provides a one-line command to run the Konarr agent as a container. This is the quickest way to start monitoring containers on a host.

**Command Structure:**

```bash
docker run \
  -e "KONARR_INSTANCE=<your-instance-url>" \
  -e "KONARR_AGENT_TOKEN=<auto-generated-token>" \
  -e "KONARR_PROJECT_ID=<project-id>" \
  -v "/var/run/docker.sock:/var/run/docker.sock:ro" \
  ghcr.io/42bytelabs/konarr-agent:latest
```

**Environment Variables:**

| Variable | Description | Example |
|----------|-------------|---------|
| `KONARR_INSTANCE` | Konarr server URL | `http://localhost:9000` or `https://konarr.example.com` |
| `KONARR_AGENT_TOKEN` | Authentication token (auto-populated from server settings) | Generated by server on first startup |
| `KONARR_PROJECT_ID` | Target project ID | Automatically filled with current project ID |

**Volume Mount:**

- `/var/run/docker.sock:/var/run/docker.sock:ro` - Read-only access to Docker socket for container discovery and scanning

**Using the Docker Command:**

1. Click **"Show"** to reveal the command
2. Click **"Copy"** to copy to clipboard
3. Execute on your container host
4. Agent will automatically start scanning and reporting to this project

**Security Notes:**

- The Docker socket mount provides read-only access for container inspection
- Agent token is automatically retrieved from server settings
- Command is pre-configured with current project context

#### Kubernetes Deployment

The Kubernetes section provides a complete deployment manifest for running the Konarr agent in a Kubernetes cluster. This is ideal for monitoring containerized workloads in K8s environments.

**Manifest Structure:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: konarr-agent
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: konarr-agent
    spec:
      containers:
        - name: konarr-agent
          image: ghcr.io/42bytelabs/konarr-agent:latest
          env:
            - name: KONARR_INSTANCE
              value: "<your-instance-url>"
            - name: KONARR_AGENT_TOKEN
              value: "<auto-generated-token>"
            - name: KONARR_PROJECT_ID
              value: "<project-id>"
```

**Environment Variables:**

The Kubernetes manifest uses the same environment variables as the Docker deployment:

| Variable | Description | Auto-Populated |
|----------|-------------|----------------|
| `KONARR_INSTANCE` | Konarr server URL from browser location | Yes |
| `KONARR_AGENT_TOKEN` | Authentication token from server settings | Yes |
| `KONARR_PROJECT_ID` | Current project ID | Yes |

**Deploying to Kubernetes:**

1. Click **"Show"** to reveal the manifest
2. Click **"Copy"** to copy to clipboard
3. Save to a file (e.g., `konarr-agent.yaml`)
4. Apply to your cluster:

   ```bash
   kubectl apply -f konarr-agent.yaml
   ```

5. Verify deployment:

   ```bash
   kubectl get pods -l app=konarr-agent
   kubectl logs -l app=konarr-agent
   ```

**Production Considerations:**

- **Secrets Management**: Consider using Kubernetes Secrets for `KONARR_AGENT_TOKEN`
- **RBAC Permissions**: Agent may require additional permissions for cluster-wide scanning
- **Resource Limits**: Add CPU/memory limits based on cluster size
- **Namespace**: Deploy to appropriate namespace for organizational needs

**Example with Secrets:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: konarr-agent-secret
type: Opaque
stringData:
  token: "<your-agent-token>"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: konarr-agent
spec:
  template:
    spec:
      containers:
        - name: konarr-agent
          env:
            - name: KONARR_AGENT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: konarr-agent-secret
                  key: token
```

#### Manual SBOM Upload

The Manual Upload section allows you to upload pre-generated SBOM files directly to the project. This is useful for:

- **Testing and Validation**: Upload sample SBOMs to test Konarr's analysis capabilities
- **CI/CD Integration**: Upload SBOMs generated in build pipelines
- **Historical Data**: Import existing SBOM data from previous scans
- **Non-Container Workloads**: Upload SBOMs for applications that don't run in containers
- **Offline Scanning**: Upload SBOMs generated in air-gapped environments

**Supported SBOM Formats:**

- **CycloneDX**: JSON and XML formats
- **SPDX**: JSON and XML formats (if supported by server)

**Upload Process:**

1. Click **"Select SBOM File"** button
2. Choose your SBOM file from the file picker (`.json` or `.xml`)
3. Review the selected file name
4. Click **"Upload"** to submit
5. Server processes the SBOM and creates a new snapshot
6. View the processed snapshot with dependencies and vulnerabilities

**Generating SBOMs for Upload:**

You can generate SBOMs using various scanning tools:

**Syft (CycloneDX format):**

```bash
syft <image-or-directory> -o cyclonedx-json > sbom.json
```

**Trivy (CycloneDX format):**

```bash
trivy image --format cyclonedx <image-name> > sbom.json
```

**Grype (after Syft generation):**

```bash
syft <image> -o cyclonedx-json | grype --add-cpes-if-none
```

**Upload Feedback:**

- **Success**: Redirects to the new snapshot view
- **Error**: Displays error message (invalid format, file size, network issues)
- **Progress**: Shows "Uploading..." status during submission

**File Requirements:**

- Maximum file size: Depends on server configuration (typically several MB)
- Valid CycloneDX or SPDX format
- Must contain component and dependency information
- JSON and XML extensions accepted

**Troubleshooting Upload Issues:**

- **Invalid Format**: Verify SBOM file is valid CycloneDX/SPDX format
- **Network Errors**: Check connection to Konarr server
- **Authentication**: Ensure you're logged in with appropriate permissions
- **File Size**: Large SBOMs may require server configuration changes

**Security Considerations:**

- Manual uploads are logged and associated with your user account
- Uploaded SBOMs are processed immediately for vulnerabilities
- Files are validated before storage to prevent malicious content

---

## Snapshots and SBOMs

### Understanding Snapshots

Snapshots represent the state of a container or system at a specific time:

- **Automatic Creation**: Generated when agents scan containers
- **Manual Triggers**: Can be triggered through the API or agent commands
- **Versioning**: Multiple snapshots per project show changes over time

### Viewing SBOM Details

Click on any snapshot to access detailed information:

- **Dependencies**: Complete list of packages, libraries, and components with pagination
- **Vulnerability Data**: Security scan results and risk assessments
- **Metadata**: Scan tool information, timestamps, and container details
- **Export Options**: Download SBOM data in various formats (JSON, XML)

### Uploading SBOMs

Projects can now accept manually uploaded SBOM files:

- **Access**: Navigate to project setup page
- **Supported Formats**: JSON and XML SBOM files (CycloneDX, SPDX)
- **Use Cases**:
  - Manual snapshot creation from external scans
  - Import historical SBOM data
  - Testing and validation workflows
- **Process**:
  1. Click "Upload SBOM" button on the project setup page
  2. Select your SBOM file (JSON or XML format)
  3. Confirm upload to create a new snapshot
  4. View the processed snapshot with dependencies and vulnerabilities

### SBOM Standards

Konarr uses industry-standard SBOM formats:

- **CycloneDX**: Primary format for SBOM generation and storage
- **SPDX**: Alternative format support
- **Tool Integration**: Works with Syft, Grype, Trivy, and other scanning tools

### Dependency Navigation

Browse and search through project dependencies:

- **Pagination**: Navigate through large dependency lists efficiently
- **URL Persistence**: Page numbers are preserved in the URL for bookmarking
- **Search Functionality**: Filter dependencies by name or package identifier
- **Details View**: Click any dependency to view detailed information
- **Vulnerability Mapping**: See which dependencies have known vulnerabilities

The pagination feature automatically updates the URL with the current page, making it easy to share specific dependency views with team members.

---

## Security Alerts

### Alert Overview

Security alerts are automatically generated from vulnerability scans:

- **Source**: Generated from tools like Grype and Trivy
- **Severity Levels**: Critical, High, Medium, Low, Unknown
- **Real-time Updates**: Alerts update as new snapshots are created

### Alert Management

- **Filtering**: Filter by severity, state, search terms, or CVE IDs
- **State Management**: Mark alerts as Acknowledged or Secure
- **Bulk Operations**: Handle multiple alerts simultaneously
- **Triage Workflow**: Use alerts to prioritize security remediation

### Alert Details

Each alert provides comprehensive information:

- **Vulnerability Description**: Detailed CVE information and impact
- **Affected Components**: Which packages/dependencies are vulnerable
- **Severity Assessment**: Risk level and CVSS scores where available
- **Remediation**: Version upgrade recommendations and fix information

---

## Settings and Administration

### User Management

Admin users can manage system access with an enhanced interface:

- **User Accounts**: Create and manage user accounts with improved UI
- **Role Assignment**: Assign admin or standard user privileges
- **Status Management**: Activate, deactivate, or suspend user accounts
- **User Search**: Find users quickly with search and filtering
- **Pagination**: Navigate through large user lists efficiently
- **Session Management**: Monitor active sessions and access logs
- **Bulk Operations**: Manage multiple users efficiently

The updated admin interface provides better visibility and control over user accounts, with real-time statistics showing total, active, and inactive user counts.

### Agent Token Management

Configure agent authentication:

- **Token Generation**: Server auto-generates agent tokens on first startup
- **Token Retrieval**: Access current agent token through admin interface
- **Token Security**: Rotate tokens for enhanced security

### Server Configuration

Access server-level settings:

- **Network Configuration**: Domain, port, and proxy settings
- **Security Settings**: Authentication, secrets, and access controls
- **Feature Toggles**: Enable/disable specific Konarr features
- **Performance Settings**: Database cleanup, retention policies

---

## Typical Workflow

### Initial Setup

1. **Start Server**: Launch Konarr server and access web interface
2. **Admin Login**: Log in with admin credentials
3. **Configure Settings**: Set up agent tokens and server configuration
4. **Setup Profile**: Optionally configure your user profile and password
5. **Agent Setup**: Configure and deploy agents to monitor containers or upload SBOMs manually

### Daily Operations

1. **Monitor Projects**: Review project status and recent snapshots
2. **Browse Dependencies**: Navigate through dependency lists with pagination
3. **Review Alerts**: Triage new security vulnerabilities
4. **Investigate Issues**: Drill down into specific snapshots and dependencies
5. **Take Action**: Update containers, acknowledge alerts, or escalate issues

### Ongoing Management

1. **Trend Analysis**: Monitor security trends across projects
2. **Compliance Reporting**: Export SBOMs for compliance requirements
3. **System Maintenance**: Review server health and performance metrics
4. **User Management**: Manage access and permissions as team grows (admin only)
5. **Profile Updates**: Keep passwords current and review active sessions

---

## Navigation Tips

### Search and Filtering

- **Global Search**: Use the search box on Projects and Snapshots pages
- **Filter Options**: Filter by project type, status, severity, or date ranges
- **Quick Access**: Bookmark frequently accessed projects for easy navigation
- **URL Parameters**: Pagination states are preserved in URLs for sharing

### Keyboard Shortcuts

- **Navigation**: Use browser back/forward for quick page navigation
- **Refresh**: F5 or Ctrl+R to refresh data views
- **Search**: Click search boxes or use Tab navigation

### Performance Optimization

- **Pagination**: Large datasets are automatically paginated for performance
- **URL Sync**: Page numbers persist in URLs for seamless navigation
- **Lazy Loading**: Detailed data loads on-demand when viewing specific items
- **Caching**: Web interface caches frequently accessed data

---

## Export and Automation

### Manual Export

Export data directly from the web interface:

- **SBOM Export**: Download complete SBOM data from snapshot detail pages
- **Vulnerability Reports**: Export security scan results
- **Project Data**: Export project summaries and statistics

### API Integration

For automation and integration:

- **REST API**: Complete API access for all web interface functionality
- **Authentication**: Use session cookies for web-based API access
- **Documentation**: See [API Documentation](05-api.md) for complete endpoint reference

### Reporting

Generate reports for compliance and management:

- **Security Summaries**: Aggregate vulnerability data across projects
- **Compliance Reports**: SBOM data for regulatory requirements
- **Trend Analysis**: Historical data for security and dependency trends

---

## Troubleshooting

### Common Issues

**Web Interface Not Loading**:

1. Check server is running: `curl http://localhost:9000/api/health`
2. Verify frontend configuration in server settings
3. Clear browser cache and cookies
4. Check network connectivity and firewall settings

**Authentication Problems**:

1. Verify admin user account exists
2. Check session timeout settings
3. Clear browser cookies and re-login
4. Verify server authentication configuration

**Performance Issues**:

1. Check server resource usage (CPU, memory, disk)
2. Review database performance and size
3. Consider implementing reverse proxy caching
4. Monitor network latency and bandwidth

### Additional Help

For more troubleshooting information:

- **[Troubleshooting Guide](07-troubleshooting.md)** - Comprehensive troubleshooting procedures
- **[Configuration Guide](03-configuration.md)** - Server and web interface configuration
- **[Security Setup](06-security.md)** - Authentication and security configuration

---

## Next Steps

After familiarizing yourself with the web interface:

- **[User Profile](#user-profile-management)** - Manage your account and password settings
- **[CLI Usage](03-usage-cli.md)** - Learn about command-line operations
- **[API Documentation](05-api.md)** - Integrate with external systems
- **[Security Guide](06-security.md)** - Implement production security practices
