# Konarr Documentation - AI Coding Agent Instructions

This repository contains the official documentation for Konarr, a lightweight container supply chain monitoring tool.
The documentation is built using MDBook and follows specific conventions for structure, style, and content.
The language of the documentation is English and has an audience of developers, system administrators, and security people familiar with container security concepts.

All documentation must adhere to the guidelines outlined below to ensure consistency and clarity across the project.

**Critical Guidelines:**

- You MUST read both related repositories (server and client) to understand the full architecture before making changes.
- You MUST follow the established documentation structure and conventions (see `.github/instructions/docs.instructions.md`).
- You MUST ensure all code examples and configuration snippets are accurate and up-to-date with source code.
- You MUST use the specified terminology: `container` (not "Docker" or "Podman"), `agent` (not "client"), `SBOM` (not "software bill of materials" after first use).
- You MUST validate changes with `mdbook serve` locally before committing.
- You MUST run `markdownlint '**.md' --ignore node_modules --disable MD013` and ensure zero output.

## Project Architecture

**Documentation Structure:**

- `src/SUMMARY.md`: Navigation structure and table of contents (hierarchical, MUST be updated when adding pages)
- `src/*.md`: Documentation pages with numbered prefixes indicating sections
  - `01-` = Introduction (overview, features, architecture)
  - `02-` = Installation/Setup (server, agent, Docker, Kubernetes)
  - `03-` = Configuration/Usage (server config, agent config, CLI, tools)
  - `04-` = Web Interface
  - `05-` = API (comprehensive REST API docs with auth details)
  - `06-` = Security
  - `07-` = Troubleshooting
- `book.toml`: MDBook configuration (minimal - authors, language, source dir)
- `.github/instructions/docs.instructions.md`: File-level instructions for documentation editing (auto-applied to `**/*.md`)

**Build System:**

- MDBook v0.4.32 for static site generation (Rust-based documentation tool)
- `vercel-build.sh`: Custom build script for Vercel deployment (downloads mdbook binary, runs build)
- Local development: `mdbook serve` (live reload on `http://localhost:3000`)
- Production build: `mdbook build` (outputs to `book/` directory, gitignored)
- **No package.json or Node dependencies** - pure MDBook + markdownlint workflow

**Related Repositories (Source of Truth for Technical Details):**

- Main project: <https://github.com/42ByteLabs/konarr> (Rust server with Rocket framework, GeekORM, SQLite)
- Client: <https://github.com/42bytelabs/konarr-client> (Vue.js + TypeScript frontend)
- **IMPORTANT**: Always cross-reference source code when documenting configuration options, API endpoints, or default values

## Documentation Conventions

**Language and Style:**

- Use `container` instead of "Docker" or "Podman" for general references
- Active voice, clear and concise, minimal jargon
- Code examples use `bash`, `yaml`, or `toml` fence markers
- Markdown tables for parameters/options (columns: name, description, default value)

**Content Organization:**

- Step-by-step instructions for procedures
- Configuration examples show environment variables AND YAML format
- Architecture documented: Server (Rust/Rocket/SQLite) + Agent/CLI (Rust) + Frontend (Vue.js/TypeScript)
- Key technologies: GeekORM for database, Figment for config, CycloneDX for SBOMs, Syft/Grype/Trivy for scanning

**Links and References:**

- Prefer linking to existing sections over duplicating content
- External tool links: GitHub repos and official documentation
- Configuration precedence: `konarr.yml` file < Environment vars < CLI flags
- Environment variable prefixes: `KONARR_` (server), `KONARR_AGENT_` (agent)

## Development Workflow

**Essential Commands (Run These First):**

```bash
# Install MDBook (one-time setup, requires Rust/Cargo)
cargo install mdbook

# Serve with live reload - ALWAYS test changes here before committing
mdbook serve
# Opens at http://localhost:3000 with auto-refresh on file changes

# Build static files (for CI/deployment verification)
mdbook build
```

**Quality Checks (Must Pass Before Commit):**

```bash
# Run markdown linter - output MUST be empty (zero errors/warnings)
markdownlint '**.md' --ignore node_modules --disable MD013
# MD013 (line length) is intentionally disabled
```

**Critical Pre-Commit Checklist:**

1. ✅ Test with `mdbook serve` - verify navigation, rendering, code blocks
2. ✅ Run `markdownlint` - ensure zero output
3. ✅ Update `src/SUMMARY.md` if adding new pages
4. ✅ Verify all internal links use relative paths (`./03-file.md` not `/03-file.md`)
5. ✅ Check that code blocks have proper language markers (`bash`, `yaml`, `toml`)

**Key Files to Check When Making Changes:**

- Adding new pages → Update `src/SUMMARY.md` navigation hierarchy
- Changing page numbering → Update all affected file prefixes and SUMMARY.md
- Modifying config examples → Cross-check with source code defaults
- Before committing → Verify `book/` directory is gitignored (build artifacts)

## Common Tasks

**Adding New Documentation Page:**

1. Create file with numbered prefix matching section (e.g., `src/03-new-feature.md`)
2. **CRITICAL**: Add entry to `src/SUMMARY.md` in appropriate hierarchy (MDBook won't discover page otherwise)
3. Follow heading structure: H1 for page title, H2/H3 for sections (no H4+)
4. Include code examples with appropriate language markers (`bash`, `yaml`, `toml`, `json`)
5. Use markdown tables for configuration parameters (columns: name, description, default)
6. Test with `mdbook serve` to verify navigation and rendering before commit

**Example Page Structure:**

```markdown
# Page Title

Brief introduction paragraph.

## Main Section

Content with examples:

\```yaml
# Example YAML configuration
server:
  port: 9000
\```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `server.port` | HTTP port | `9000` |
```

**Updating Configuration Examples:**

- **MUST** show both environment variable and YAML file approaches (users need both)
- Include markdown table with parameter details (name, description, default value)
- **CRITICAL**: Cross-reference actual defaults from source code - don't guess!
  - Server defaults: port `9000`, data path `/data`, config `/config/konarr.yml`
  - Agent defaults: Check konarr-client repo for accurate values
- Use `KONARR_` prefix for server env vars, `KONARR_AGENT_` for agent vars

**Cross-Referencing Documentation:**

- Use relative links with `./` prefix: `[Server Configuration](./03-configuration-server.md)`
- Link to specific sections with anchors: `[API Auth](./05-api.md#authentication)`
- Prefer linking to existing content over duplicating explanations
- When referencing external tools: Link to official docs (Syft, Grype, Trivy GitHub repos)
- **Link to source code when relevant**: Add GitHub links to specific files/functions when documenting implementation details (e.g., configuration parsing, API endpoints, database schemas)

## Important Context

**Container Deployment Defaults (Memorize These):**

- Data path: `/data` (env: `KONARR_DATA_PATH`)
- Config file: `/config/konarr.yml` (env: `KONARR_CONFIG_PATH`)
- HTTP port: `9000` (env: `KONARR_SERVER_PORT`)
- Database: SQLite at `/data/konarr.db` (auto-created on first run)
- Frontend path: `frontend/build` (baked into container)

**Supported Scanning Tools (External Dependencies):**

- **Syft** (<https://github.com/anchore/syft>): SBOM generation (primary tool)
- **Grype** (<https://github.com/anchore/grype>): Vulnerability scanning (Anchore)
- **Trivy** (<https://github.com/aquasecurity/trivy>): Comprehensive security scanner (Aqua Security)
- Agents can auto-install and update these tools via CLI flags

**Key Architecture Points:**

- **Server-Agent model**: Agents push snapshots/SBOMs to server via REST API (not pull-based)
- **Authentication**: Session cookies for web UI (HTTP-only `x-konarr-token`), Bearer tokens for agents
- **Database**: SQLite with GeekORM for type-safe queries (single-file, no external DB needed)
- **SBOM Format**: CycloneDX v1.5 and v1.6 (industry standard, JSON format)
- **API Versioning**: Currently unversioned (`/api/` prefix), future versions will use `/api/v2/`
- **Configuration precedence**: CLI flags > Environment vars > `konarr.yml` file > Defaults

**Common Documentation Patterns:**

- Docker Compose examples: Always include volumes for `/data` and `/config`, healthcheck, restart policy
- Kubernetes examples: Include persistent volume claims, config maps, secrets for agent tokens
- API documentation: Show both `curl` examples and response schemas with all fields documented
- Configuration tables: Always show parameter name, description, and default value (3 columns)
