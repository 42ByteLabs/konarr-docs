# Konarr Documentation - AI Coding Agent Instructions

This repository contains the official documentation for Konarr, a lightweight container supply chain monitoring tool. The documentation is built using MDBook and follows specific conventions for structure, style, and content.

## Project Architecture

**Documentation Structure:**

- `src/SUMMARY.md`: Navigation structure and table of contents (hierarchical)
- `src/*.md`: Documentation pages with numbered prefixes indicating sections
  - `01-` = Introduction
  - `02-` = Installation/Setup
  - `03-` = Configuration/Usage
  - `04-` = Web Interface
  - `05-` = API
  - `06-` = Security
  - `07-` = Troubleshooting
- `book.toml`: MDBook configuration (minimal - authors, language, source dir)

**Build System:**

- MDBook for static site generation
- `vercel-build.sh`: Custom build script for Vercel deployment (downloads mdbook binary v0.4.32)
- Local development: `mdbook serve` (live reload on `http://localhost:3000`)
- Production build: `mdbook build` (outputs to `book/` directory)

**Related Repositories:**

- Main project: https://github.com/42ByteLabs/konarr (Rust server with Rocket framework)
- Client: https://github.com/42bytelabs/konarr-client (Vue.js + TypeScript frontend)

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

**Local Testing:**

```bash
# Install MDBook (if not installed)
cargo install mdbook

# Serve with live reload
mdbook serve

# Build static files
mdbook build
```

**Linting:**

```bash
# Run markdown linter (must pass with no output)
markdownlint '**.md' --ignore node_modules --disable MD013
```

**Key Files to Check:**

- When adding new pages: Update `src/SUMMARY.md` navigation
- When changing structure: Verify `book.toml` configuration
- Before committing: Test build locally and run linting

## Common Tasks

**Adding New Documentation Page:**

1. Create file with numbered prefix matching section (e.g., `src/03-new-feature.md`)
2. Add entry to `src/SUMMARY.md` in appropriate hierarchy
3. Follow heading structure: H1 for page title, H2/H3 for sections
4. Include code examples with appropriate language markers
5. Test with `mdbook serve` to verify navigation and rendering

**Updating Configuration Examples:**

- Show both environment variable and YAML file approaches
- Include table with parameter details (name, description, default)
- Reference actual defaults from source code (Server: port 9000, data path: `/data`)

**Cross-Referencing:**

- Use relative links: `[Server Configuration](03-configuration-server.md)`
- Link to specific sections: `[API Documentation](05-api.md#authentication)`

## Important Context

**Container Deployment Defaults:**

- Data path: `/data` (KONARR_DATA_PATH)
- Config file: `/config/konarr.yml`
- HTTP port: 9000
- Database: SQLite at `/data/konarr.db`

**Supported Scanning Tools:**

- Syft: SBOM generation (primary)
- Grype: Vulnerability scanning (Anchore)
- Trivy: Comprehensive security scanner (Aqua Security)

**Key Architecture Points:**

- Server-Agent architecture (agents push data to server via REST API)
- Session-based auth for web UI, bearer token for agents
- SQLite with GeekORM for database operations
- CycloneDX v1.5/v1.6 for SBOM format
