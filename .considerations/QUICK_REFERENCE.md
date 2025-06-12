# Quick Reference - Technical Decisions

## Key Decisions Made

### Architecture
- **Firecracker VMs** over Docker containers for stronger isolation
- **GraphQL** over REST for flexible client queries
- **PostgreSQL** for environment versioning (git-like model)
- **Rust** backend for performance and Nix FFI
- **SolidJS** frontend for minimal bundle size and reactivity

### Development Practices
- **NixOS-first** - All dependencies in flake.nix
- **TDD** - Tests before implementation
- **Atomic commits** - One feature per commit
- **Pre-commit hooks** - Automated quality checks

## Common Patterns

### Error Handling (Rust)
```rust
use anyhow::Result;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    // ... other variants
}
```

### GraphQL Resolvers
```rust
#[Object]
impl QueryRoot {
    async fn environment(&self, ctx: &Context<'_>, id: ID) -> Result<Environment> {
        // Implementation
    }
}
```

## Performance Considerations
- Use connection pooling for PostgreSQL
- Implement DataLoader pattern for N+1 queries
- Cache Nix store paths aggressively
- Lazy-load frontend routes

## Security Checklist
- [ ] JWT tokens expire appropriately
- [ ] Input validation on all endpoints
- [ ] SQL injection protection (use parameterized queries)
- [ ] XSS protection in frontend
- [ ] CORS properly configured
- [ ] Secrets in environment variables, not code