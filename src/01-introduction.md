# Introduction

Konarr is a blazing fast, lightweight web interface for monitoring your servers, clusters, and containers' supply chains for dependencies and vulnerabilities. Written in Rust 🦀, it provides minimal resource usage while delivering real-time insights into your software bill of materials (SBOM) and security posture.

## Key Features

- **Simple, easy-to-use web interface** with both light and dark modes
- **Blazing fast performance** with minimal resource usage (written in Rust 🦀)
- **Real-time container monitoring** using industry-standard scanners:
  - [Syft](https://github.com/anchore/syft) for SBOM generation
  - Grype and Trivy for vulnerability scanning
- **Orchestration support** for:
  - Docker / Podman
  - Docker Compose / Docker Swarm
  - Kubernetes support (planned 🚧)
- **Software Bill of Materials (SBOM)** generation and management for containers
- **Supply chain attack monitoring** (in development 🚧)
- **CycloneDX support** (v1.5 and v1.6) for SBOM formats

## Architecture

Konarr follows a simple server + agent architecture:

- **Server**: Built with Rust and the Rocket framework
  - Provides REST API and web UI  
  - Uses SQLite for lightweight data storage (GeekORM for database operations)
  - Stores server settings including agent authentication keys
  - Serves frontend built with VueJS and TypeScript
  - Default port: 9000

- **Agent / CLI**: Rust-based CLI (`konarr-cli`) that:
  - Runs in monitoring mode (watches Docker socket for container events)
  - Generates SBOMs using configurable tools (Syft, Grype, Trivy)
  - Uploads snapshots and vulnerability data to the server
  - Supports auto-creation of projects
  - Can auto-install and update scanning tools

- **Extensible tooling**:
  - Tool discovery and management system
  - Support for multiple package managers:
    - **Language Ecosystems**: Cargo (Rust), NPM (JavaScript/Node.js), PyPI (Python), Maven/Gradle (Java/JVM), Go Modules, Nuget (.NET)
    - **System Packages**: Deb (Debian/Ubuntu), RPM (Red Hat/CentOS/Fedora), Apk (Alpine)
    - **Container Technologies**: Docker, OCI containers
  - Standardized SBOM and vulnerability report uploading

## Technologies Used

Konarr is built with modern, high-performance technologies:

**Backend:**
- **Rust** using Rocket framework for the web server
- **GeekORM** for database operations and SQLite integration
- **Figment** for configuration management
- **Tokio** for asynchronous runtime

**Frontend:**
- **Vue.js 3** with TypeScript for reactive UI
- **Tailwind CSS** for responsive styling
- **Vite** for fast development and building
- **Material Design Icons (MDI)** and Heroicons for UI icons
- **HeadlessUI** for accessible UI components

**Database:**
- **SQLite** for lightweight, embedded data storage
- **GeekORM** for type-safe database operations
- Automatic migrations and schema management

**Security & Standards:**
- **CycloneDX** (v1.5 and v1.6) for SBOM format compliance
- **Session-based authentication** for web UI
- **Bearer token authentication** for agents
- **CORS support** for API access

**Container & Deployment:**
- **Docker** and **Podman** support
- **Docker Compose** configurations
- **Kubernetes** support (planned)
- **Multi-architecture** container images (x86_64, ARM64)

## Quick Links

- [Installation & Setup](02-installation.md)
- [Server Setup](02-server.md)
- [Agent Setup](02-agent.md)
- [Configuration & Usage](03-configuration.md)
- [API Documentation](05-api.md)
- [Security](06-security.md)
- [API Documentation](05-api.md)
- [Security](06-security.md)

## Getting Started

1. **Install the Server** - See [Server Installation](02-server.md)
2. **Configure Authentication** - Retrieve the agent token from the server
3. **Deploy Agents** - See [Agent Installation](02-agent.md) to monitor your containers
4. **Monitor Projects** - View SBOMs and vulnerabilities in the [web interface](04-usage-web.md)

For a quick start using Docker, see our [installation guide](02-installation.md).

---

**Project Repository**: [https://github.com/42ByteLabs/konarr](https://github.com/42ByteLabs/konarr)  
**Frontend Repository**: [https://github.com/42ByteLabs/konarr-client](https://github.com/42ByteLabs/konarr-client)  
**Container Images**: Available on [GitHub Container Registry](https://github.com/42ByteLabs/konarr/pkgs/container/konarr)  
**License**: Apache 2.0
