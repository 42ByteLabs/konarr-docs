# Security Alerts

This guide covers how to manage security alerts and vulnerabilities in Konarr.

## Alert Overview

Security alerts are automatically generated from vulnerability scans:

- **Source**: Generated from tools like Grype and Trivy
- **Severity Levels**: Critical, High, Medium, Low, Unknown
- **Real-time Updates**: Alerts update as new snapshots are created

### How Alerts are Generated

When agents scan containers or when SBOMs are uploaded:

1. **Scanning**: Tools analyze dependencies and components
2. **Vulnerability Detection**: Known CVEs are identified in packages
3. **Alert Creation**: Konarr creates alerts for each vulnerability found
4. **Severity Assignment**: Alerts are categorized by risk level
5. **Project Association**: Alerts are linked to the affected project

### Alert Lifecycle

Alerts go through different states as they are managed:

- **Vulnerable** (Default): Active security issue requiring attention
- **Acknowledged**: Known issue, currently being investigated or addressed
- **Secure**: Issue has been resolved, mitigated, or deemed not applicable

---

## Alert Management

### Viewing Alerts

Access security alerts through multiple views:

- **Global Alerts**: View all alerts across all projects from the main navigation
- **Project Alerts**: See alerts specific to a project in the project view
- **Snapshot Alerts**: View alerts detected in a specific snapshot

### Filtering Alerts

Use filtering options to focus on relevant alerts:

- **Severity Filtering**: Filter by Critical, High, Medium, Low, or Unknown
- **State Filtering**: Show only Vulnerable, Acknowledged, or Secure alerts
- **Search**: Search by CVE identifier, component name, or description
- **Project Filtering**: Filter alerts by specific projects
- **Date Range**: View alerts discovered within a specific time period

### Alert Actions

Manage individual alerts or perform bulk operations:

**Individual Alert Actions:**

- **View Details**: Click an alert to see full vulnerability information
- **Acknowledge**: Mark alert as acknowledged while working on resolution
- **Mark Secure**: Indicate that the vulnerability has been resolved or mitigated
- **View Affected Projects**: See all projects impacted by this vulnerability
- **Export**: Download alert data for reporting or analysis

**Bulk Operations:**

- **Bulk Acknowledge**: Acknowledge multiple alerts simultaneously
- **Bulk Mark Secure**: Mark multiple alerts as secure
- **Bulk Export**: Export multiple alerts for compliance reporting

### Triage Workflow

Recommended workflow for managing security alerts:

1. **Review New Alerts**: Check alerts in Vulnerable state
2. **Assess Priority**: Focus on Critical and High severity alerts first
3. **Investigate**: Review CVE details, affected components, and impact
4. **Acknowledge**: Mark alerts as acknowledged while working on fixes
5. **Remediate**: Update dependencies, apply patches, or implement mitigations
6. **Verify**: Trigger new scans to confirm vulnerabilities are resolved
7. **Mark Secure**: Update alert state once issue is addressed

---

## Alert Details

### Vulnerability Information

Each alert provides comprehensive information:

**Basic Information:**

- **CVE Identifier**: Unique identifier for the vulnerability (e.g., CVE-2023-12345)
- **Description**: Detailed explanation of the security issue
- **Severity Level**: Risk assessment (Critical, High, Medium, Low)
- **Discovery Date**: When the vulnerability was first detected
- **Last Updated**: Most recent update to vulnerability information

**Affected Components:**

- **Package Name**: The vulnerable dependency or component
- **Current Version**: Version containing the vulnerability
- **Fixed Version**: Version where the vulnerability is patched (if available)
- **Package Type**: Library, framework, system package, etc.

**Risk Assessment:**

- **CVSS Score**: Common Vulnerability Scoring System rating (if available)
- **CVSS Vector**: Technical scoring details
- **Attack Complexity**: How difficult the vulnerability is to exploit
- **Impact**: Potential consequences (confidentiality, integrity, availability)

**Remediation Guidance:**

- **Recommended Action**: Upgrade path or mitigation steps
- **Version Upgrade**: Specific version to upgrade to
- **Workarounds**: Alternative solutions if upgrade isn't possible
- **References**: Links to CVE databases, security advisories, and patch notes

### Affected Projects

View which projects are impacted by a specific vulnerability:

- **Project List**: All projects containing the vulnerable component
- **Version Information**: Which versions of the component are present
- **Last Scan**: When each project was last scanned
- **Navigation**: Click projects to view their full details

This helps identify the scope of a vulnerability across your infrastructure and prioritize remediation efforts.

---

## Alert Statistics and Reporting

### Dashboard Views

Get an overview of your security posture:

- **Total Alert Count**: Number of active security alerts
- **Severity Distribution**: Breakdown by Critical, High, Medium, Low
- **Trend Analysis**: How alert counts change over time
- **Most Common CVEs**: Frequently detected vulnerabilities
- **Most Affected Projects**: Projects with highest vulnerability counts

### Generating Reports

Export alert data for compliance and reporting:

- **CSV Export**: Spreadsheet format for analysis
- **JSON Export**: Structured data for automation and integration
- **Filtered Exports**: Export specific subsets of alerts
- **Historical Reports**: Track vulnerability trends over time

---

## Integration with Scanning Tools

Konarr integrates with multiple security scanning tools:

### Grype

**Anchore Grype** vulnerability scanner:

- Scans container images and filesystems
- Matches packages against vulnerability databases
- Provides detailed CVE information
- Regular database updates for latest vulnerabilities

See the [Scanning Tools documentation](03-tools.md) for Grype configuration.

### Trivy

**Aqua Security Trivy** comprehensive scanner:

- Multi-purpose vulnerability and misconfiguration scanner
- Supports containers, filesystems, repositories
- Fast scanning with accurate results
- Regular vulnerability database updates

See the [Scanning Tools documentation](03-tools.md) for Trivy configuration.

### Custom Scanners

Konarr can work with any scanner that produces:

- **CycloneDX SBOMs** with vulnerability information
- **SPDX SBOMs** with security annotations
- Standard vulnerability data formats

---

## Best Practices

### Regular Scanning

- **Scheduled Scans**: Configure agents to scan regularly (daily or weekly)
- **Triggered Scans**: Scan after deploying new versions or updates
- **Continuous Monitoring**: Keep agents running for real-time detection

### Managing Alerts

- **Timely Review**: Check new alerts daily or weekly
- **Priority Focus**: Address Critical and High severity alerts first
- **Documentation**: Document remediation decisions and workarounds
- **Team Communication**: Share alert information with relevant teams

### Remediation Strategy

- **Automated Updates**: Use automated dependency updates where possible
- **Testing**: Test updates in non-production environments first
- **Rollback Plan**: Have rollback procedures for problematic updates
- **Temporary Mitigations**: Implement workarounds if immediate updates aren't feasible

### Compliance and Auditing

- **Regular Exports**: Generate periodic reports for compliance
- **Audit Trail**: Document all alert state changes
- **Retention Policy**: Archive historical alert data
- **Evidence Collection**: Keep records of remediation actions

---

## Troubleshooting

### Alerts Not Appearing

If expected alerts aren't showing:

1. **Verify Scanning**: Check that agents are running and scanning
2. **Check Tool Configuration**: Ensure Grype or Trivy is configured
3. **Database Updates**: Verify vulnerability databases are current
4. **SBOM Quality**: Ensure SBOMs contain complete dependency information
5. **Log Review**: Check server logs for processing errors

### False Positives

If alerts appear incorrectly:

1. **Verify Versions**: Check that package versions are correctly identified
2. **Review CVE Details**: Confirm the vulnerability applies to your usage
3. **Check Applicability**: Determine if affected code paths are used
4. **Mark Secure**: Use with documentation explaining why it's not applicable
5. **Report Issues**: Report false positives to scanning tool maintainers

### Missing Vulnerability Data

If known vulnerabilities aren't detected:

1. **Update Databases**: Ensure scanning tools have latest vulnerability data
2. **Re-scan**: Trigger a new scan after database updates
3. **SBOM Completeness**: Verify all dependencies are captured in SBOMs
4. **Tool Coverage**: Some vulnerabilities may only be detected by specific tools
5. **Manual Review**: Cross-reference with external vulnerability databases

---

## Additional Resources

For more information on related topics:

- **[Projects](04-projects.md)** - Project management and organization
- **[Dependencies](04-dependencies.md)** - Understanding SBOMs and dependency tracking
- **[Scanning Tools](03-tools.md)** - Configuration for Grype, Trivy, and other scanners
- **[API Documentation](05-api.md)** - Automate alert management via API
- **[Security Configuration](06-security.md)** - Server security and authentication
