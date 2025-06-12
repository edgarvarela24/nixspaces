# CLAUDE.md - NixSpaces Development Environment Platform

## Project Overview
NixSpaces is a cloud-based development environment platform that leverages NixOS's unique capabilities to provide "Branch Everything" functionality - allowing developers to branch not just code, but entire development environments including system dependencies, services, and configurations.

## Core Principles
- **NixOS First**: Every design decision prioritizes NixOS's unique capabilities
- **Test-Driven Development**: All features must have tests before implementation
- **Developer Experience**: Make NixOS invisible until its power is needed
- **Reproducibility**: Every environment must be bit-for-bit reproducible

## Development Approach
1. Use TDD for all new features - write tests first
2. Keep sessions focused - one feature per Claude Code session
3. Commit frequently with clear messages
4. Update this file when adding new patterns or conventions

## Tech Stack
- **Backend**: Rust (chosen for excellent Nix integration and performance)
- **Frontend**: SolidJS (lightweight, reactive, perfect for real-time updates)
- **Infrastructure**: NixOS containers with Firecracker microVMs
- **Storage**: PostgreSQL with git-like environment versioning
- **API**: GraphQL for flexible client queries

## Project Structure
```
nixspaces/
├── flake.nix            # Nix development environment and build configuration
├── flake.lock           # Locked dependencies for reproducibility
├── .envrc               # Direnv integration for automatic environment loading
├── .gitignore           # Git ignore patterns (Nix-aware)
├── CLAUDE.md            # This file - project context and guidelines
├── sprint_plan.md       # Sprint planning and task tracking
│
├── backend/             # Rust GraphQL API server
│   ├── Cargo.toml       # Rust dependencies and configuration
│   ├── src/
│   │   └── main.rs      # Application entry point
│   ├── migrations/      # SQL migrations (managed by sqlx)
│   └── tests/           # Backend unit and integration tests
│
├── frontend/            # SolidJS web application
│   ├── package.json     # Node dependencies
│   ├── vite.config.ts   # Vite bundler configuration
│   ├── tsconfig.json    # TypeScript configuration
│   ├── index.html       # HTML entry point
│   ├── src/
│   │   └── index.tsx    # Application entry point
│   ├── public/          # Static assets
│   └── tests/           # Frontend tests
│
├── nix/                 # Nix modules and overlays
│   ├── modules/         # Custom NixOS modules
│   └── overlays/        # Nix package overlays
│
├── tests/               # Cross-cutting tests
│   ├── integration/     # Full-stack integration tests
│   └── e2e/             # End-to-end tests (Playwright)
│
├── scripts/             # Utility scripts
├── .claude/             # Claude AI work context
├── .reviews/            # Code review tracking
├── .considerations/     # Technical decisions and debt
├── .design/             # Design documentation
└── .docs/               # Project documentation
    ├── ARCHITECTURE.md  # System architecture
    └── MVP_SPEC.md      # MVP specification
```

## 🚀 NixOS-First Development

### Essential Commands (using `just`)
```bash
# Enter development shell with all tools
nix develop
# Or use direnv (recommended)
direnv allow

# Then use just for all development tasks:
just          # Show all available commands
just dev      # Start development servers (backend + frontend)
just test     # Run all tests
just t        # Quick test (shortcut)
just t test_name  # Run specific test
just fmt      # Format all code
just lint     # Run linters
just c        # Quick cargo check
just r        # Quick cargo run

# Database management
just db-start    # Start PostgreSQL
just db-stop     # Stop PostgreSQL
just db-init     # Initialize PostgreSQL (first time)
just db-reset    # Reset PostgreSQL (delete all data)
just db-cli      # Open PostgreSQL CLI
just db-status   # Check PostgreSQL status

# Migrations
just migrate-new NAME  # Create new migration
just migrate-run       # Run migrations (or just 'm')
just migrate-revert    # Revert last migration
just migrate-info      # Show migration status

# Check flake health
nix flake check

# Update dependencies
nix flake update
```

### Development Setup
1. **First time setup:**
   ```bash
   # Initialize database
   just db-init
   
   # Install frontend dependencies (auto-done by nix develop)
   cd frontend && pnpm install && cd ..
   ```

2. **Daily workflow:**
   ```bash
   # Option 1: Use direnv (automatic)
   cd /path/to/nixspaces
   # Environment loads automatically
   just dev  # Start development
   
   # Option 2: Manual
   nix develop
   just dev  # Start development
   ```

### Nix Best Practices
- **NEVER** install tools globally - add them to `flake.nix`
- **ALWAYS** use `nix develop` or `direnv` for consistent environment
- **UPDATE** flake.lock regularly: `nix flake update`
- **TEST** in clean environment: `nix develop --ignore-environment`
- **PIN** specific versions in flake inputs when needed
- **USE** `nix run` for all project commands

### Pre-commit Hooks
Pre-commit hooks are automatically installed when entering the dev shell:
- Nix formatting (nixpkgs-fmt, alejandra)
- Nix linting (statix, deadnix)
- Rust formatting and linting
- Frontend formatting and linting
- Secret scanning (gitleaks)
- File cleanup (trailing spaces, EOF)

## Key Commands
All development commands are managed through `just`. After entering the nix shell (`nix develop` or via direnv), run:

```bash
just          # List all available commands
just dev      # Start development environment
just test     # Run all tests
just t        # Quick test runner (accepts arguments)
just fmt      # Format code
just lint     # Run linters
```

For a complete list of commands, see the `justfile` in the project root.

## 📁 Project Structure Maintenance
**IMPORTANT**: Always keep the project structure in this file up to date when:
- Adding new directories or significant files
- Reorganizing existing structure
- Adding new configuration files
- Creating new test directories

This helps maintain clarity and ensures everyone understands the codebase layout.

## Testing Strategy
- Unit tests for all business logic
- Integration tests for API endpoints
- System tests for Nix environment operations
- Property-based tests for environment reproducibility

## Git Workflow
- Branch naming: `feature/description` or `fix/description`
- Commit format: `type(scope): description`
- Always run tests before committing
- Keep commits atomic and focused

## Error Handling
- Use Rust's Result type consistently
- Never panic in production code
- Log errors with context
- Provide meaningful error messages to users

## When to Ask Questions
ALWAYS ask before:
- Adding new dependencies
- Changing API contracts
- Modifying Nix configurations
- Implementing security-sensitive features

## 📋 Current Sprint Context
@./sprint_plan.md
@./.reviews/current-review.md
@./.considerations/QUICK_REFERENCE.md

## 🔄 Active Work Context
@./.claude/work-context/current-task.md
@./.claude/work-context/test-notes.md
@./.claude/work-context/implementation-notes.md
@./.claude/work-context/review-pipeline.md

## Current Phase
Building MVP focusing on:
1. Basic environment creation from Nix flakes
2. Environment branching and versioning
3. Simple web interface for environment management
4. Container orchestration with resource limits

## References
- Architecture details: @.docs/ARCHITECTURE.md
- MVP specification: @.docs/MVP_SPEC.md
- Technical debt tracking: @./.considerations/TECHNICAL_DEBT_SUMMARY.md
