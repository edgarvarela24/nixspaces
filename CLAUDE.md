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

### Essential Nix Commands
```bash
# Enter development shell with all tools
nix develop

# Or use direnv (recommended)
direnv allow

# Run specific commands without entering shell
nix run .#dev       # Start development servers (backend + frontend)
nix run .#test      # Run all tests
nix run .#fmt       # Format all code
nix run .#lint      # Run all linters
nix run .#db        # Database management (start|stop|init|reset|cli|status)
nix run .#migrate   # Migration tools (new|run|revert|info)
nix run .#gql       # GraphQL tools (playground|schema|codegen)
nix run .#sec       # Security checks
nix run .#bench     # Run benchmarks
nix run .#docs      # Build/serve documentation

# Check flake health
nix flake check

# Update dependencies
nix flake update
```

### Development Setup
1. **First time setup:**
   ```bash
   # Initialize database
   nix run .#db -- init
   
   # Install frontend dependencies (auto-done by nix develop)
   cd frontend && pnpm install && cd ..
   ```

2. **Daily workflow:**
   ```bash
   # Option 1: Use direnv (automatic)
   cd /path/to/nixspaces
   # Environment loads automatically
   
   # Option 2: Manual
   nix develop
   nix run .#dev
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

## Key Commands - Functions Written In flake.nix
- `nix run .#dev` - Start both backend and frontend in tmux
- `nix run .#test` - Run all tests (backend + frontend)
- `nix run .#fmt` - Format all code (Rust, Nix, JS/TS)
- `nix run .#lint` - Run all linters
- `nix run .#db -- {start|stop|init|reset|cli|status}` - Database management
- `nix run .#migrate -- {new|run|revert|info}` - Database migrations
- `nix run .#gql -- {playground|schema|codegen}` - GraphQL tools
- `nix run .#sec` - Run security checks
- `nix run .#bench -- {rust|api|db|all}` - Run benchmarks
- `nix run .#docs -- {build|serve}` - Documentation
- `nix flake check` - Run all flake checks
- `nix develop` - Enter development shell
- `nix build` - Build production artifacts

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
