# Konarr Documentation

This is the official documentation repository for [Konarr](https://github.com/42ByteLabs/konarr), a lightweight web interface for monitoring container supply chains, dependencies, and vulnerabilities.

## About

Konarr is a monitoring tool written in Rust that provides real-time insights into your container infrastructure's Software Bill of Materials (SBOM) and security posture. This documentation covers installation, configuration, and usage of both the server and agent components.

## Building the Documentation

This documentation is built with [MDBook](https://rust-lang.github.io/mdBook/). To build locally:

```bash
# Install MDBook
cargo install mdbook

# Serve locally (with live reload)
mdbook serve

# Build static files
mdbook build
```

## Contributing

See the project's [main repository](https://github.com/42ByteLabs/konarr) for contribution guidelines.
