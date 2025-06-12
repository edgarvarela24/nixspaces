# Sprint Plan - NixSpaces

## Previous Sprint: Sprint 0 - Project Setup ✅
**Duration**: 1 day
**Goal**: Set up development environment and prepare for MVP development
**Status**: Completed

### Completed Tasks
- [x] Create comprehensive flake.nix with all development dependencies
- [x] Set up project directory structure
- [x] Initialize Rust backend with Cargo.toml
- [x] Initialize SolidJS frontend with package.json
- [x] Create .gitignore with Nix-aware patterns
- [x] Update CLAUDE.md with Nix-specific instructions
- [x] Create .envrc for direnv integration
- [x] Add sprint_plan.md template

---

## Current Sprint: Sprint 1 - Foundation
**Duration**: 5 days
**Goal**: Build core API foundation with GraphQL and basic frontend structure for accepting GitHub URLs

### Context
This sprint lays the groundwork for our MVP by establishing the core API structure and basic frontend. We'll implement the fundamental GraphQL API that all future features will build upon, create the initial frontend with URL input capability, and ensure our development workflow is solid with proper testing infrastructure.

### Priority Order
1. [ ] **Backend GraphQL API Setup** - Set up Axum server with async-graphql, implement health check endpoint, and create basic GraphQL schema with query/mutation roots. TDD: Write integration tests for GraphQL endpoint availability and health check.

2. [ ] **Database Schema & Migrations** - Design initial database schema for environments table, set up SQLx migrations, and implement connection pooling. TDD: Write tests for database connectivity and migration runner.

3. [ ] **Core Environment Types & Repository** - Create Rust types for Environment entity, implement repository pattern for database access, and add CRUD operations for environments. TDD: Write unit tests for repository methods using test fixtures.

4. [ ] **GraphQL Environment Resolvers** - Implement createEnvironment mutation (accepting GitHub URL), getEnvironment query, and basic error handling. TDD: Write GraphQL integration tests using async-graphql test utilities.

5. [ ] **Frontend Foundation** - Set up SolidJS with Vite, create basic routing structure, implement landing page with GitHub URL input field, and add loading states. TDD: Write component tests using Vitest.

6. [ ] **Frontend-Backend Integration** - Set up GraphQL client (urql or similar), implement environment creation flow, add proper error handling and user feedback. TDD: Write E2E tests for the complete flow using Playwright.

7. [ ] **Development Tooling** - Fix test runner to properly use cargo nextest, set up pre-commit hooks, add GitHub Actions CI workflow. TDD: Ensure all test commands work correctly.

### Technical Debt (20%)
- [ ] Fix flake.nix issues (duplicate shellHook, test runner configuration)
- [ ] Set up proper logging infrastructure with tracing

### Notes
- Key decisions:
  - Use async-graphql for type-safe GraphQL implementation
  - SQLx for compile-time checked SQL queries
  - Repository pattern to separate business logic from data access
  - urql for frontend GraphQL client (lightweight and SolidJS-friendly)
- Blockers: None currently identified
- Dependencies: PostgreSQL must be running for backend development

### Prerequisites
- Enter dev shell: `nix develop` or use direnv
- Initialize database: `nix run .#db -- init`
- Verify environment: `cargo --version && node --version`
- All dependencies are managed via Nix - no manual installation needed

---

## Sprint Template

## Sprint N: [Sprint Name]
**Duration**: [X days/weeks]
**Goal**: [Clear sprint goal]

### Priority Order
1. [ ] Task 1 - [Description]
2. [ ] Task 2 - [Description]
3. [ ] Task 3 - [Description]
4. [ ] Task 4 - [Description]
5. [ ] Task 5 - [Description]

### Technical Debt (20%)
- [ ] Debt item 1
- [ ] Debt item 2

### Notes
- Key decisions:
- Blockers:
- Dependencies:

---

## Backlog (Future Sprints)

### High Priority
- [ ] Basic environment creation from GitHub URL
- [ ] Flake.nix auto-detection and generation
- [ ] VS Code web integration
- [ ] Terminal websocket connection
- [ ] Environment state persistence

### Medium Priority
- [ ] Branch/commit switching
- [ ] URL-based sharing
- [ ] Resource limits implementation
- [ ] Error handling and recovery

### Low Priority
- [ ] Performance optimizations
- [ ] Monitoring and metrics
- [ ] Documentation improvements

## Sprint Methodology Reminders
- Each task should be atomic and testable
- Balance new features (80%) with technical debt (20%)
- TDD: Write tests before implementation
- Complete the task, nothing more (avoid feature creep)
- Update this file at the start and end of each sprint