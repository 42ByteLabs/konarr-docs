# Introduction

Konarr is a blazing fast, lightweight web interface for monitoring your servers, clusters, and containers' supply chains for dependencies and vulnerabilities. Written in [Rust](https://www.rust-lang.org/) 🦀, it provides minimal resource usage while delivering real-time insights into your software bill of materials (SBOM) and security posture.

## Key Features

- **Simple, easy-to-use web interface** with both light and dark modes
- **Blazing fast performance** with minimal resource usage (written in [Rust](https://www.rust-lang.org/) 🦀)
- **Real-time container monitoring** using industry-standard scanners:
  - [Syft](https://github.com/anchore/syft) for SBOM generation
  - [Grype](https://github.com/anchore/grype) and [Trivy](https://github.com/aquasecurity/trivy) for vulnerability scanning
- **Orchestration support** for:
  - [Docker](https://www.docker.com/) / [Podman](https://podman.io/)
  - [Docker Compose](https://docs.docker.com/compose/) / [Docker Swarm](https://docs.docker.com/engine/swarm/)
  - [Kubernetes](https://kubernetes.io/) support (planned 🚧)
- **Software Bill of Materials (SBOM)** generation and management for containers
- **Supply chain attack monitoring** (in development 🚧)
- **[CycloneDX](https://cyclonedx.org/) support** (v1.5 and v1.6) for SBOM formats

## Architecture

Konarr follows a simple server + agent architecture:

- **Server**: Built with [Rust](https://www.rust-lang.org/) and the [Rocket](https://rocket.rs/) framework
  - Provides REST API and web UI  
  - Uses [SQLite](https://www.sqlite.org/) for lightweight data storage ([GeekORM](https://github.com/42ByteLabs/GeekORM) for database operations)
  - Stores server settings including agent authentication keys
  - Serves frontend built with [Vue.js](https://vuejs.org/) and [TypeScript](https://www.typescriptlang.org/)
  - Default port: 9000

- **Agent / CLI**: [Rust](https://www.rust-lang.org/)-based CLI (`konarr-cli`) that:
  - Runs in monitoring mode (watches [Docker](https://www.docker.com/) socket for container events)
  - Generates SBOMs using configurable tools ([Syft](https://github.com/anchore/syft), [Grype](https://github.com/anchore/grype), [Trivy](https://github.com/aquasecurity/trivy))
  - Uploads snapshots and vulnerability data to the server
  - Supports auto-creation of projects
  - Can auto-install and update scanning tools

- **Extensible tooling**:
  - Tool discovery and management system
  - Support for multiple package managers:
    - **Language Ecosystems**: [Cargo](https://doc.rust-lang.org/cargo/) (Rust), [NPM](https://www.npmjs.com/) (JavaScript/Node.js), [PyPI](https://pypi.org/) (Python), [Maven](https://maven.apache.org/)/[Gradle](https://gradle.org/) (Java/JVM), [Go Modules](https://go.dev/ref/mod), [Nuget](https://www.nuget.org/) (.NET)
    - **System Packages**: [Deb](https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html) (Debian/Ubuntu), [RPM](https://rpm.org/) (Red Hat/CentOS/Fedora), [Apk](https://wiki.alpinelinux.org/wiki/Package_management) (Alpine)
    - **Container Technologies**: [Docker](https://www.docker.com/), [OCI containers](https://opencontainers.org/)
  - Standardized SBOM and vulnerability report uploading

## Technologies Used

Konarr is built with modern, high-performance technologies:

**Backend:**

- **[Rust](https://www.rust-lang.org/)** using [Rocket](https://rocket.rs/) framework for the web server
- **[GeekORM](https://github.com/42ByteLabs/GeekORM)** for database operations and [SQLite](https://www.sqlite.org/) integration
- **[Figment](https://github.com/SergioBenitez/Figment)** for configuration management
- **[Tokio](https://tokio.rs/)** for asynchronous runtime

**Frontend:**

- **[Vue.js 3](https://vuejs.org/)** with [TypeScript](https://www.typescriptlang.org/) for reactive UI
- **[Tailwind CSS](https://tailwindcss.com/)** for responsive styling
- **[Vite](https://vitejs.dev/)** for fast development and building
- **[Material Design Icons (MDI)](https://materialdesignicons.com/)** and [Heroicons](https://heroicons.com/) for UI icons
- **[HeadlessUI](https://headlessui.com/)** for accessible UI components

**Database:**

- **[SQLite](https://www.sqlite.org/)** for lightweight, embedded data storage
- **[GeekORM](https://github.com/42ByteLabs/GeekORM)** for type-safe database operations
- Automatic migrations and schema management

**Security & Standards:**

- **[CycloneDX](https://cyclonedx.org/)** (v1.5 and v1.6) for SBOM format compliance
- **Session-based authentication** for web UI
- **Bearer token authentication** for agents
- **CORS support** for API access

**Container & Deployment:**

- **[Docker](https://www.docker.com/)** and **[Podman](https://podman.io/)** support
- **[Docker Compose](https://docs.docker.com/compose/)** configurations
- **[Kubernetes](https://kubernetes.io/)** support (planned)
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
