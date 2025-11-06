# Security Alerts

Manage security alerts and vulnerabilities detected in your projects.

## Alert Overview

Alerts are automatically generated from vulnerability scans (Grype, Trivy) when agents scan containers or SBOMs are uploaded.

**Severity Levels:** Critical, High, Medium, Low, Unknown

**Alert States:**

- **Vulnerable**: Active security issue requiring attention
- **Acknowledged**: Known issue being investigated
- **Secure**: Resolved, mitigated, or not applicable

---

## Alert Management

### Viewing and Filtering

Access alerts from:

- **Global view**: All alerts across projects
- **Project view**: Project-specific alerts
- **Snapshot view**: Alerts from a specific scan

Filter by severity, state, CVE identifier, or project.

### Actions

**Individual:**

- View details, acknowledge, mark secure, or export

**Bulk:**

- Acknowledge or mark secure multiple alerts simultaneously

### Triage Workflow

1. Review new alerts (focus on Critical/High severity)
2. Investigate CVE details and affected components
3. Acknowledge while working on fixes
4. Remediate (update dependencies, apply patches)
5. Re-scan to verify resolution
6. Mark secure when resolved

---

## Alert Details

Each alert includes:

- CVE identifier, description, severity
- Affected package, current/fixed versions
- CVSS score and attack complexity
- Remediation guidance and upgrade path
- List of impacted projects

---

## Reporting

Export alert data:

- CSV/JSON formats for analysis
- Filter by severity, project, or date range
- Track trends over time

---

## Scanning Tools

Konarr integrates with:

- **Grype** (Anchore): Container and filesystem scanning
- **Trivy** (Aqua Security): Multi-purpose vulnerability scanner
- **Custom scanners**: Any tool producing CycloneDX or SPDX SBOMs

See [Scanning Tools](03-tools.md) for configuration.

---

## Best Practices

- Schedule regular scans (daily/weekly)
- Scan after deployments
- Review Critical/High alerts first
- Document remediation decisions
- Test updates before production deployment
- Export reports for compliance

---

## Troubleshooting

**Missing alerts:** Verify agents are scanning, tool configuration is correct, and vulnerability databases are updated

**False positives:** Verify package versions, review CVE applicability, mark as secure with documentation

See also: [Projects](04-projects.md) | [Dependencies](04-dependencies.md) | [Scanning Tools](03-tools.md)
