# Dependencies and SBOMs

This guide covers how to view, manage, and understand Software Bill of Materials (SBOM) data and dependency information in Konarr.

## Understanding Snapshots

Snapshots represent the state of a container or system at a specific point in time. They capture a complete picture of dependencies, components, and vulnerability status.

### What is a Snapshot?

A snapshot includes:

- **SBOM Data**: Complete list of dependencies and components
- **Timestamp**: When the snapshot was created
- **Metadata**: Information about the scanned target (container, host, etc.)
- **Scan Tool Info**: Which tools generated the SBOM (Syft, Trivy, etc.)
- **Vulnerability Data**: Security scan results at the time of capture

### Snapshot Creation

Snapshots are created through multiple methods:

**Automatic Creation:**

- **Agent Scans**: When agents scan containers or systems
- **Scheduled Scans**: Agents can be configured to scan on schedules
- **Event-Triggered**: Scans triggered by container updates or deployments

**Manual Creation:**

- **Manual Triggers**: Through the API or agent commands
- **SBOM Upload**: Upload pre-generated SBOM files through the web interface
- **CI/CD Integration**: Upload SBOMs from build pipelines

### Snapshot Versioning

Multiple snapshots per project show changes over time:

- **Historical Tracking**: See how dependencies change across versions
- **Comparison**: Compare snapshots to identify new or removed dependencies
- **Trend Analysis**: Track vulnerability trends over time
- **Rollback Reference**: Use historical snapshots to understand past configurations

---

## Viewing SBOM Details

Click on any snapshot to access detailed information about dependencies and components.

### Snapshot Overview

The snapshot detail page provides:

- **Summary Statistics**:
  - Total number of dependencies
  - Vulnerability counts by severity
  - Scan timestamp and duration
- **Metadata Information**:
  - Container image name and tag
  - Host or system information
  - Scanning tool details
- **Navigation Options**:
  - View full dependency list
  - Jump to specific components
  - Export SBOM data

### Dependencies List

The dependencies section shows all components found in the snapshot:

**Dependency Information:**

- **Package Name**: Name of the component or library
- **Version**: Specific version detected
- **Package Type**: Library, framework, OS package, etc.
- **License**: Software license information (if available)
- **Source**: Where the package comes from (npm, pip, apt, etc.)

**Navigation Features:**

- **Pagination**: Navigate through large dependency lists efficiently
- **URL Persistence**: Page numbers are preserved in the URL for bookmarking
- **Search Functionality**: Filter dependencies by name or identifier
- **Sort Options**: Sort by name, version, or vulnerability count

### Dependency Details

Click on any dependency to view detailed information:

- **Version Information**: Specific version and available updates
- **License Details**: Complete license information and compatibility
- **Vulnerability Status**: Known security issues in this version
- **Usage Information**: Where and how the dependency is used
- **Dependencies**: Other packages this component depends on
- **Dependents**: Other packages that depend on this component

### Vulnerability Mapping

Dependencies with known vulnerabilities are clearly marked:

- **Visual Indicators**: Icons or badges showing vulnerability presence
- **Severity Display**: Color coding by severity level
- **CVE Links**: Direct links to vulnerability details
- **Fix Information**: Recommended versions or mitigation steps

---

## Dependency Navigation

Efficiently browse and search through project dependencies.

### Pagination

Navigate through large dependency lists:

- **Automatic Pagination**: Large datasets are split into manageable pages
- **Items Per Page**: Configurable number of dependencies shown per page
- **URL-Based**: Page numbers in URL allow bookmarking and sharing
- **Keyboard Navigation**: Use browser back/forward buttons

**Example URL Structure:**

```text
/projects/123/snapshots/456/dependencies?page=2
```

This makes it easy to:

- Share specific dependency pages with team members
- Bookmark frequently reviewed dependency sets
- Navigate back to previous views

### Search and Filtering

Find specific dependencies quickly:

**Search Options:**

- **Package Name**: Search by exact or partial package names
- **Version**: Filter by specific version numbers
- **License**: Find all packages with a particular license
- **Vulnerability Status**: Show only vulnerable dependencies

**Filter Combinations:**

Combine multiple filters for precise results:

- Vulnerable packages with GPL licenses
- All npm packages in a specific version range
- Packages without license information

### Dependency Comparison

Compare dependencies between snapshots:

- **Side-by-Side View**: Compare two snapshots
- **Added Dependencies**: New packages in the latest snapshot
- **Removed Dependencies**: Packages no longer present
- **Updated Dependencies**: Packages with version changes
- **Unchanged Dependencies**: Packages that remain the same

This helps identify:

- Impact of updates and changes
- Dependency drift over time
- Security improvements or regressions

---

## SBOM Standards

Konarr uses industry-standard SBOM formats for maximum compatibility.

### CycloneDX

**Primary SBOM format:**

- **Versions Supported**: CycloneDX 1.5 and 1.6
- **Format Options**: JSON and XML
- **Features**:
  - Comprehensive component information
  - Vulnerability data integration
  - Dependency relationships
  - License information
  - Pedigree and provenance tracking

**Use Cases:**

- Container image SBOMs
- Application dependency tracking
- Security vulnerability management
- Compliance reporting

### SPDX

**Alternative SBOM format:**

- **Format Options**: JSON and XML
- **Features**:
  - Software package data exchange
  - License compliance focus
  - Industry-standard format
  - Wide tool support

**Use Cases:**

- License compliance verification
- Open source governance
- Supply chain transparency
- Legal and regulatory requirements

### Format Conversion

Konarr can work with multiple formats:

- **Import**: Upload CycloneDX or SPDX SBOMs
- **Processing**: Internal normalization for consistent handling
- **Export**: Download in original or converted format
- **API Access**: Retrieve SBOMs in preferred format

---

## Tool Integration

Konarr integrates with multiple scanning tools for SBOM generation.

### Syft

**Primary SBOM generation tool:**

- **Purpose**: Generate SBOMs from container images and filesystems
- **Output Formats**: CycloneDX, SPDX, and custom formats
- **Coverage**: Detects dependencies across multiple ecosystems
- **Performance**: Fast scanning with accurate results

**Using Syft:**

```bash
# Generate CycloneDX SBOM
syft <image-or-directory> -o cyclonedx-json > sbom.json

# Scan Docker image
syft docker:alpine:latest -o cyclonedx-json

# Scan directory
syft dir:/path/to/project -o cyclonedx-json
```

See the [Scanning Tools documentation](03-tools.md) for detailed Syft configuration.

### Grype

**Vulnerability scanner:**

- **Purpose**: Scan SBOMs and images for vulnerabilities
- **Integration**: Works with Syft-generated SBOMs
- **Output**: Adds vulnerability data to existing SBOMs
- **Database**: Regular updates from multiple sources

**Using Grype:**

```bash
# Scan image with Grype
grype <image-name>

# Scan with Syft SBOM
syft <image> -o cyclonedx-json | grype --add-cpes-if-none
```

See the [Scanning Tools documentation](03-tools.md) for Grype configuration.

### Trivy

**Comprehensive security scanner:**

- **Purpose**: Multi-purpose vulnerability and SBOM scanner
- **Output Formats**: CycloneDX, SPDX, and custom formats
- **Coverage**: Containers, filesystems, repositories, configurations
- **Features**: Vulnerabilities, misconfigurations, secrets

**Using Trivy:**

```bash
# Generate CycloneDX SBOM
trivy image --format cyclonedx <image-name> > sbom.json

# Scan with vulnerability detection
trivy image --format json <image-name>

# Scan filesystem
trivy fs --format cyclonedx /path/to/project
```

See the [Scanning Tools documentation](03-tools.md) for Trivy configuration.

---

## Uploading SBOMs

Manually upload pre-generated SBOM files to create snapshots.

### Upload Methods

**Web Interface:**

1. Navigate to project setup page
2. Click "Upload SBOM" or "Select SBOM File"
3. Choose SBOM file (`.json` or `.xml`)
4. Click "Upload" to submit
5. View the created snapshot

**API Upload:**

Use the REST API to upload SBOMs programmatically:

```bash
curl -X POST https://konarr.example.com/api/projects/123/sboms \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d @sbom.json
```

See the [API Documentation](05-api.md) for complete endpoint details.

### Supported Formats

**File Formats:**

- **JSON**: CycloneDX JSON or SPDX JSON
- **XML**: CycloneDX XML or SPDX XML

**File Requirements:**

- Valid SBOM format structure
- Must contain component and dependency information
- Maximum file size depends on server configuration (typically several MB)
- JSON and XML file extensions

### Use Cases for Manual Upload

**CI/CD Integration:**

- Upload SBOMs generated during build process
- Integrate with pipeline tools (Jenkins, GitLab CI, GitHub Actions)
- Automate SBOM submission after image builds

**Testing and Validation:**

- Test Konarr's analysis capabilities with sample SBOMs
- Validate SBOM processing and vulnerability detection
- Compare results from different scanning tools

**Historical Data:**

- Import existing SBOM data from previous scans
- Migrate data from other systems
- Maintain historical records

**Non-Container Workloads:**

- Upload SBOMs for applications not running in containers
- Track dependencies for serverless functions
- Monitor standalone applications and services

**Offline Scanning:**

- Generate SBOMs in air-gapped environments
- Transfer SBOMs via secure channels
- Upload to Konarr instance accessible from secure networks

### Upload Feedback

**Success Response:**

- Redirects to new snapshot view
- Shows processing status
- Displays dependency and vulnerability counts

**Error Handling:**

- **Invalid Format**: SBOM doesn't match expected structure
- **File Size**: File exceeds maximum size limit
- **Network Errors**: Connection issues with server
- **Authentication**: Invalid or missing credentials

---

## Export and Reporting

### Exporting SBOM Data

Download SBOM data for various purposes:

**Export Formats:**

- **JSON**: CycloneDX or SPDX JSON format
- **XML**: CycloneDX or SPDX XML format
- **CSV**: Simplified dependency list for spreadsheets
- **Custom**: API access for custom format generation

**Export Options:**

- **Full SBOM**: Complete snapshot with all data
- **Dependency List**: Just the components and versions
- **Vulnerability Report**: Security-focused export
- **License Report**: License compliance information

### Compliance Reporting

Generate reports for compliance and auditing:

**Regulatory Compliance:**

- Software composition documentation
- License compliance verification
- Supply chain transparency
- Security vulnerability reporting

**Report Types:**

- **Dependency Reports**: Complete list of components
- **License Reports**: Software license inventory
- **Vulnerability Reports**: Security assessment
- **Change Reports**: Dependency changes over time

---

## Best Practices

### Regular Scanning

- **Scheduled Scans**: Set up regular snapshot creation
- **Event-Driven**: Scan after deployments or updates
- **Continuous Monitoring**: Keep agents running for current data

### SBOM Management

- **Version Control**: Keep historical snapshots for comparison
- **Documentation**: Document snapshot purposes and contexts
- **Retention Policy**: Define how long to keep snapshots
- **Export Backups**: Regularly export SBOM data for archival

### Dependency Tracking

- **Regular Review**: Periodically review dependency lists
- **Update Planning**: Use SBOM data to plan dependency updates
- **License Compliance**: Monitor license changes and compatibility
- **Security Monitoring**: Track vulnerable dependencies

---

## Troubleshooting

### SBOM Upload Issues

**Invalid Format Errors:**

- Verify SBOM is valid CycloneDX or SPDX
- Check JSON/XML syntax
- Validate against schema
- Test with scanning tool documentation

**File Size Issues:**

- Check server configuration for size limits
- Consider splitting large SBOMs
- Compress repeated data
- Contact administrator for limit increases

**Processing Errors:**

- Review server logs for details
- Verify SBOM contains required fields
- Check for malformed data
- Test with minimal SBOM first

### Missing Dependencies

If expected dependencies aren't showing:

- Verify scanning tool configuration
- Check scan coverage and depth
- Review SBOM generation logs
- Ensure all package managers are detected

---

## Additional Resources

For more information on related topics:

- **[Projects](04-projects.md)** - Project management and setup
- **[Security Alerts](04-security.md)** - Managing vulnerabilities
- **[Scanning Tools](03-tools.md)** - Configuration for Syft, Grype, Trivy
- **[API Documentation](05-api.md)** - Programmatic SBOM management
- **[Agent Configuration](03-agent.md)** - Agent setup and scanning
