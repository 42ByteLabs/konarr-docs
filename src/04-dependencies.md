# Dependencies and SBOMs

View and manage Software Bill of Materials (SBOM) data and dependency information.

## Understanding Snapshots

Snapshots capture the state of a container or system at a specific time, including SBOM data, dependencies, vulnerabilities, and scan metadata.

### Snapshot Creation

**Automatic:**

- Agent scans (scheduled or event-triggered)
- Container updates or deployments

**Manual:**

- API triggers
- SBOM file uploads via web interface
- CI/CD pipeline integration

### Versioning

Multiple snapshots per project enable:

- Historical dependency tracking
- Snapshot comparison
- Vulnerability trend analysis

---

## Viewing SBOM Details

### Snapshot Overview

Each snapshot shows:

- Dependency count and vulnerability summary
- Container/host metadata and scan tool info
- Export options

### Dependencies List

View all components with:

- Package name, version, type, license
- Search, filter, and pagination
- URL-based page numbers for bookmarking

### Dependency Details

Click dependencies to view:

- Version info and available updates
- License details
- Vulnerability status with CVE links
- Package relationships (dependencies/dependents)

### Comparison

Compare snapshots to identify:

- Added, removed, or updated dependencies
- Dependency drift over time
- Security improvements or regressions

---

## SBOM Standards

Konarr supports industry-standard SBOM formats:

- **CycloneDX** (primary): v1.5/1.6, JSON/XML
- **SPDX** (alternative): JSON/XML

Both formats support vulnerability data, dependency relationships, and license information.

---

## Tool Integration

### Syft

Generate SBOMs from containers and filesystems:

```bash
syft <image-or-directory> -o cyclonedx-json > sbom.json
```

### Grype

Scan for vulnerabilities:

```bash
grype <image-name>
syft <image> -o cyclonedx-json | grype --add-cpes-if-none
```

### Trivy

Multi-purpose scanner with SBOM generation:

```bash
trivy image --format cyclonedx <image-name> > sbom.json
```

See [Scanning Tools](03-tools.md) for configuration details.

---

## Uploading SBOMs

Upload SBOMs via web interface or API for CI/CD integration, testing, or offline scanning.

**Web Interface:** Project Setup → Upload SBOM

**API:**

```bash
curl -X POST https://konarr.example.com/api/projects/123/sboms \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d @sbom.json
```

**Supported:** CycloneDX and SPDX (JSON/XML)

See [API Documentation](05-api.md) for details.

---

## Export and Reporting

Export SBOMs in JSON, XML, or CSV formats for:

- Compliance documentation
- License verification
- Vulnerability assessment
- Dependency tracking

---

## Best Practices

- Schedule regular scans
- Keep historical snapshots for comparison
- Review dependencies periodically
- Monitor license compliance
- Export data for compliance

---

## Troubleshooting

**Upload errors:** Verify SBOM format and file size limits

**Missing dependencies:** Check scanning tool configuration and SBOM completeness

See also: [Projects](04-projects.md) | [Security Alerts](04-security.md) | [Scanning Tools](03-tools.md)
