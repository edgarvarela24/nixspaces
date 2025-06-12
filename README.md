# NixSpaces - Branch Everything

A cloud-based development environment platform that leverages NixOS's unique capabilities to provide "Branch Everything" functionality - allowing developers to branch not just code, but entire development environments including system dependencies, services, and configurations.

## 🚀 Quick Start

### Prerequisites
- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) for automatic environment loading

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/nixspaces.git
cd nixspaces

# Enter the development environment
nix develop
# OR if you have direnv:
direnv allow

# Initialize the database
nix run .#db -- init

# Start development servers
nix run .#dev
```

The development environment includes:
- Backend API: http://localhost:8080
- Frontend: http://localhost:3000
- GraphQL Playground: http://localhost:8080/graphql

## 📚 Documentation

- [Architecture](./docs/ARCHITECTURE.md) - System design and technical decisions
- [MVP Specification](./docs/MVP_SPEC.md) - Minimum viable product features
- [Development Guide](./CLAUDE.md) - Development practices and guidelines

## 🛠️ Development Commands

All commands are run through Nix for consistency:

```bash
# Development
nix run .#dev       # Start backend and frontend
nix run .#test      # Run all tests
nix run .#fmt       # Format all code
nix run .#lint      # Run linters

# Database
nix run .#db -- start|stop|init|reset|cli|status
nix run .#migrate -- new|run|revert|info

# Other tools
nix run .#gql -- playground|schema|codegen
nix run .#sec       # Security checks
nix run .#bench     # Run benchmarks
nix run .#docs      # Build documentation
```

## 🏗️ Project Structure

```
nixspaces/
├── backend/        # Rust GraphQL API
├── frontend/       # SolidJS web app
├── nix/           # Nix modules and overlays
├── tests/         # Integration and e2e tests
└── flake.nix      # Development environment
```

## 🤝 Contributing

1. Always use `nix develop` for a consistent environment
2. Follow TDD - write tests first
3. Run `nix run .#fmt` before committing
4. Keep commits atomic and well-described

## 📄 License

This project is dual-licensed under MIT OR Apache-2.0.