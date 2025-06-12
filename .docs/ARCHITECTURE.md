# ARCHITECTURE.md - NixSpace Technical Architecture

## Vision
Create a development environment platform where NixOS's deterministic, reproducible nature enables developers to "branch" entire environments as easily as they branch code. This includes multiple versions of languages, databases, and system dependencies coexisting without conflicts.

## Core Innovation
**"Branch Everything"** - Not just git branches, but environment branches where developers can:
- Test PostgreSQL 13, 14, and 15 simultaneously
- Compare performance across different Node.js versions
- Instantly rollback infrastructure changes
- Share exact environments via URL

## System Architecture

### High-Level Components
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  SolidJS Web    │────▶│   Rust API      │────▶│  NixOS Engine   │
│   Interface     │     │   (GraphQL)     │     │                 │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │                          │
                               ▼                          ▼
                        ┌─────────────┐           ┌─────────────┐
                        │ PostgreSQL  │           │ Nix Store   │
                        │ (Versions)  │           │   (Cache)   │
                        └─────────────┘           └─────────────┘
```

### Environment Lifecycle

1. **Environment Creation**
   - User provides repo URL or uploads flake.nix
   - System analyzes dependencies
   - Creates immutable environment snapshot
   - Assigns unique hash identifier

2. **Environment Branching**
   - Copy-on-write branching (like git)
   - Modify dependencies without affecting parent
   - Track lineage and differences
   - Merge environments (experimental)

3. **Environment Execution**
   - Spin up Firecracker microVM
   - Mount read-only Nix store
   - Inject user code
   - Provide VS Code web interface

### Data Model

```sql
-- Environments table (git-like structure)
CREATE TABLE environments (
    id UUID PRIMARY KEY,
    hash TEXT UNIQUE NOT NULL,  -- Nix derivation hash
    parent_id UUID REFERENCES environments(id),
    name TEXT NOT NULL,
    flake_content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    created_by UUID NOT NULL
);

-- Environment versions (like git commits)
CREATE TABLE environment_versions (
    id UUID PRIMARY KEY,
    environment_id UUID REFERENCES environments(id),
    version_hash TEXT UNIQUE NOT NULL,
    message TEXT,
    changes JSONB NOT NULL,  -- Diff from parent
    created_at TIMESTAMP NOT NULL
);

-- Active sessions
CREATE TABLE sessions (
    id UUID PRIMARY KEY,
    environment_version_id UUID REFERENCES environment_versions(id),
    vm_id TEXT,
    status TEXT NOT NULL,
    started_at TIMESTAMP NOT NULL,
    last_activity TIMESTAMP NOT NULL
);
```

### Security Model

1. **Isolation Levels**
   - Network: Isolated VPC per session
   - Filesystem: Read-only system, ephemeral user data
   - Process: Firecracker VM boundaries
   - Resource: CPU/Memory quotas enforced

2. **Authentication**
   - JWT tokens for API access
   - GitHub/GitLab OAuth integration
   - Optional SSO for enterprises

### Performance Optimizations

1. **Nix Store Sharing**
   - Global binary cache
   - Content-addressed deduplication
   - Lazy fetching on demand

2. **Environment Caching**
   - Pre-built common environments
   - Incremental builds for modifications
   - Distributed build farm (future)

3. **Session Management**
   - Hibernate inactive sessions
   - Fast resume from snapshot
   - Automatic garbage collection

## Implementation Phases

### Phase 1: MVP (Month 1)
- [x] Basic environment creation from flake.nix
- [ ] Simple branching (copy environment)
- [ ] Web terminal access
- [ ] PostgreSQL for environment storage

### Phase 2: Core Features (Month 2)  
- [ ] VS Code web integration
- [ ] Environment diffing UI
- [ ] Resource limits and quotas
- [ ] Basic authentication

### Phase 3: Polish (Month 3)
- [ ] Performance optimizations
- [ ] Environment templates
- [ ] Sharing via URL
- [ ] Usage analytics

## Technical Decisions

### Why Rust?
- Excellent async performance for API
- Strong type safety for complex operations
- Good Nix FFI bindings available
- Memory safety for long-running services

### Why SolidJS?
- Minimal bundle size
- Fine-grained reactivity perfect for real-time updates
- No virtual DOM overhead
- TypeScript by default

### Why Firecracker?
- Minimal overhead vs containers
- Strong security isolation
- Fast startup times (<125ms)
- Used by AWS Lambda

### Why PostgreSQL?
- ACID compliance for environment versioning
- JSONB for flexible metadata
- Excellent Rust drivers
- Can add pgvector for future ML features

## Future Possibilities

1. **AI Integration**
   - Suggest optimal dependencies
   - Auto-generate flake.nix from code
   - Performance recommendations

2. **Collaborative Features**
   - Real-time pair programming
   - Environment pull requests
   - Team templates

3. **Enterprise Features**
   - Private Nix cache
   - Compliance scanning
   - Usage tracking

## Success Metrics

1. **Technical**
   - Environment creation: <30 seconds
   - Branch operation: <5 seconds
   - Session startup: <10 seconds

2. **User Experience**
   - Zero configuration for common stacks
   - One-click environment sharing
   - Intuitive branching UI

3. **Business**
   - 100 active users in first month
   - 1000 environments created
   - 90% user retention

## Risks and Mitigations

1. **Nix Learning Curve**
   - Mitigation: Hide complexity, provide templates

2. **Resource Costs**
   - Mitigation: Aggressive caching, usage limits

3. **Security Concerns**
   - Mitigation: Firecracker isolation, security audits

## References

- Nix manual: https://nixos.org/manual/nix/stable/
- Firecracker docs: https://firecracker-microvm.github.io/
- SolidJS docs: https://www.solidjs.com/docs/latest
- Rust async book: https://rust-lang.github.io/async-book/