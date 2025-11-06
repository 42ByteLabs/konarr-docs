# Web Interface

This guide covers how to use the Konarr web interface to monitor your containers, view SBOMs, manage projects, and track security vulnerabilities.

**Frontend Implementation**: The web interface is built with Vue.js 3 and TypeScript. Views are located in [src/views](https://github.com/42ByteLabs/konarr-client/tree/main/src/views) and components in [src/components](https://github.com/42ByteLabs/konarr-client/tree/main/src/components).

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

See the [Projects documentation](04-projects.md) for detailed information on project management and the project view.

### 📸 Snapshots

- **Purpose**: Captured states of containers or systems at specific points in time
- **Contents**: SBOM data, dependency information, vulnerability scan results
- **Features**:
  - Click snapshots to view detailed SBOM and vulnerability summaries
  - Comparison between different snapshot versions
  - Metadata including scan tools used, timestamps, and container information

See the [Dependencies and SBOMs documentation](04-dependencies.md) for detailed information on snapshots and dependency tracking.

### 🚨 Alerts

- **Purpose**: Security vulnerability alerts generated from scans
- **Contents**: Vulnerability details, severity levels, affected components
- **Features**:
  - Severity filtering (Critical, High, Medium, Low)
  - Alert state management (Vulnerable, Acknowledged, Secure)
  - Search and filtering by CVE, component, or description
  - Bulk operations for alert management

See the [Security Alerts documentation](04-security.md) for comprehensive alert management information.

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

For detailed information on creating, organizing, and managing projects, see the [Projects documentation](04-projects.md).

Key features include:

- Manual and automatic project creation
- Project types (Container, Group, Application, Server)
- Project hierarchy and organization
- Setup workflows for agents and SBOM uploads

---

## Dependencies and Snapshots

For detailed information on viewing and managing SBOMs and dependencies, see the [Dependencies and SBOMs documentation](04-dependencies.md).

Key features include:

- Understanding snapshots and SBOM data
- Dependency navigation and search
- SBOM standards (CycloneDX, SPDX)
- Manual SBOM upload
- Integration with scanning tools

---

## Security Alerts

For detailed information on managing security alerts and vulnerabilities, see the [Security Alerts documentation](04-security.md).

Key features include:

- Alert overview and lifecycle
- Filtering and bulk operations
- Alert details and remediation guidance
- Integration with vulnerability scanners

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

- **[Projects](04-projects.md)** - Detailed project management and project view
- **[Security Alerts](04-security.md)** - Managing security vulnerabilities
- **[Dependencies](04-dependencies.md)** - Understanding SBOMs and dependency tracking
- **[User Profile](#user-profile-management)** - Manage your account and password settings
- **[CLI Usage](03-usage-cli.md)** - Learn about command-line operations
- **[API Documentation](05-api.md)** - Integrate with external systems
- **[Security Configuration](06-security.md)** - Implement production security practices
