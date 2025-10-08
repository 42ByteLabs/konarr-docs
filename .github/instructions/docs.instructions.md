---
applyTo: '**/*.md'
---

You are writing documentation for the Konarr project.
Konarr is a simple, easy-to-use web interface for monitoring your servers, clusters, and containers supply chain for dependencies and vulnerabilities.
It is designed to be lightweight and fast, with minimal resource usage.

This repository uses MDBook for documentation.
All documentation files are in Markdown format and located in the `src/` directory.
Read the files in the `src/` directory to understand the structure and content of the documentation.

The source code is available for both the server and the client:
- https://github.com/42ByteLabs/konarr
- https://github.com/42bytelabs/konarr-client

Use the source code as a reference to ensure accuracy and completeness in the documentation.
If the source code changes, update the documentation accordingly.

## Technologies Used

- **Backend:**
  - Rust using Rocket framework and GeekORM for database interactions.
- **Frontend:**
  - VueJS with TypeScript for building a responsive and interactive user interface.
- **Database:**
  - SQLite for lightweight and efficient data storage.
- **Containerization:**
  - Docker or Podman for easy deployment and management.
  - Docker Compose examples provided for multi-container setups.
- **Security:**
  - Session Authentication for secure access.
  - GeekORM for safe database operations.
- **API:**
  - RESTful API design for easy integration and extensibility.

## Guidelines

- Use clear and concise language.
- Write in an active voice.
- Avoid jargon and technical terms unless necessary.
- Use headings and subheadings to organize content.
- Include code snippets and examples where applicable.
- Provide step-by-step instructions for installation and configuration.
- Use Markdown tables for arguments, options, and parameters.
  - Include name, describetion, and default value (if applicable).
- Use bullet points and numbered lists for clarity.
- Ensure all links are functional and relevant.
- Proofread for grammar and spelling errors.
- Reduce duplicate content and use links to reference existing sections.
- Follow the existing style and tone of the documentation.
- Use `container` instead of Docker or Podman when referring to the technology in general.

## Linting

Run the following command to lint the documentation:

```bash
markdownlint '**.md' --ignore node_modules --disable MD013
```

All files should pass linting without errors or warnings.
The outoutput should be empty if there are no issues.
