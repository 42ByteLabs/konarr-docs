# Projects

This guide covers how to manage projects in Konarr and understand the project view interface.

## Managing Projects

Projects in Konarr are logical groups representing hosts, applications, or container clusters. They organize your container infrastructure for monitoring and analysis.

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

---

## Project View

When you click on a project, you'll see the project detail view with several sections providing comprehensive information about your project.

### Summary

The Summary section provides an overview of the project:

- **Project Details**: Name, type, description, and metadata
- **Status Indicators**: Current health status and last update time
- **Statistics Overview**:
  - Total number of snapshots captured
  - Vulnerability counts by severity (Critical, High, Medium, Low)
  - Last scan timestamp
  - Number of dependencies tracked
- **Parent/Child Relationships**: Links to related projects in the hierarchy
- **Quick Actions**: Access to common operations like triggering scans or viewing alerts

### Sub Projects

The Sub Projects section shows child projects within the hierarchy:

- **Project List**: All projects that have this project as their parent
- **Nested Structure**: Visual representation of project hierarchy
- **Quick Navigation**: Click any sub-project to navigate to its detail view
- **Aggregated Statistics**: Summary of vulnerabilities and dependencies across all sub-projects
- **Management Actions**: Add or remove sub-projects (admin only)

This is particularly useful for:

- **Microservices Architecture**: Group related services under a parent application
- **Multi-Container Deployments**: Organize containers by function or environment
- **Infrastructure Organization**: Structure hosts by data center, region, or purpose

### Alerts

The Alerts section displays security vulnerabilities detected in the project:

- **Vulnerability List**: All active security alerts for this project
- **Severity Filtering**: Filter by Critical, High, Medium, Low severity levels
- **Alert States**:
  - **Vulnerable**: Active security issue requiring attention
  - **Acknowledged**: Known issue, currently being addressed
  - **Secure**: Issue has been resolved or mitigated
- **CVE Information**: Detailed vulnerability descriptions and identifiers
- **Affected Components**: Which dependencies are impacted by each alert
- **Quick Actions**: Acknowledge alerts, mark as secure, or view details

See the [Security Alerts documentation](04-security.md) for comprehensive alert management information.

### Dependencies

The Dependencies section shows all packages, libraries, and components detected in the project:

- **Complete Dependency List**: All components from the latest snapshot
- **Pagination**: Navigate through large dependency lists efficiently
  - URL-based pagination for bookmarking and sharing specific pages
  - Configurable items per page
- **Search Functionality**: Filter dependencies by name or package identifier
- **Dependency Details**: Click any dependency to view:
  - Package name and version
  - License information
  - Known vulnerabilities
  - Where it's used in the project
- **Vulnerability Mapping**: Visual indicators show which dependencies have security issues
- **Export Options**: Download dependency data for analysis or compliance reporting

The pagination feature automatically updates the URL with the current page number, making it easy to share specific dependency views with team members or bookmark important pages.

See the [Dependencies and SBOMs documentation](04-dependencies.md) for detailed SBOM information.

### Setup

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

## Next Steps

After understanding the project view:

- **[Security Alerts](04-security.md)** - Learn about managing security vulnerabilities
- **[Dependencies](04-dependencies.md)** - Understand SBOM data and dependency tracking
- **[Web Interface](04-usage-web.md)** - Return to the main web interface guide
