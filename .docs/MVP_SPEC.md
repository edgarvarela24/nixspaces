# MVP_SPEC.md - NixSpace MVP Specification

## MVP Goal
Build the simplest possible version that demonstrates: "Perfect environment reproduction from any point in Git history, shareable via URL"

## Core User Journey (MVP Only)

```
1. Land on nixspace.dev
2. Paste GitHub URL: github.com/user/repo
3. Wait 30-60 seconds
4. Get working environment with:
   - Web-based VS Code
   - Terminal access
   - Share button → unique URL
5. Optional: Switch git branches/commits
   - Environment updates automatically
   - Dependencies change to match
```

## What We're Building (MVP Scope)

### ✅ MUST Have
1. **Web Frontend** (SolidJS)
   - Single input field for GitHub URL
   - Loading state with progress
   - Environment view (VS Code + Terminal split)
   - Share button → copies URL
   - Basic branch/commit switcher

2. **API** (Rust + GraphQL)
   - `createEnvironment(repoUrl)` → environmentId
   - `getEnvironment(id)` → status, urls
   - `branchEnvironment(id, ref)` → newEnvironmentId
   - `shareEnvironment(id)` → shareToken

3. **NixOS Engine**
   - Auto-detect common stacks (Node, Python, Ruby, Rust, Go)
   - Generate basic flake.nix if missing
   - Support existing flake.nix files
   - Use Firecracker for isolation

4. **Supported Stacks** (auto-detected)
   ```
   - Node.js + npm/yarn/pnpm
   - Python + pip/poetry
   - Ruby + bundler
   - Rust + cargo
   - Go + go mod
   ```

### ❌ NOT in MVP
- User accounts/authentication
- Persistent storage
- Custom domains
- CLI tool
- Team features
- Billing
- Multiple running environments per user
- Docker support
- Private repos

### 🤔 Maybe (if time allows)
- Basic PostgreSQL/MySQL detection
- Redis detection
- Simple .env file support

## Technical Constraints

### Resource Limits (per environment)
- 2 vCPU
- 4GB RAM
- 10GB disk
- 1 hour timeout (then hibernates)
- Max 3 concurrent users per environment

### Security
- Read-only GitHub access (public repos only)
- No outbound internet except package registries
- No persistent storage between sessions
- Environments destroyed after 24 hours

## Success Metrics for MVP

1. **It Works**
   - Can create environment from any public GitHub repo
   - Can switch branches without breaking
   - Can share via URL

2. **It's Fast Enough**
   - Under 60 seconds for common stacks
   - Under 2 minutes for complex projects

3. **It's Stable**
   - Environments don't crash
   - VS Code stays responsive
   - No data loss during branch switches

## Development Milestones

### Week 1-2: Foundation
- [ ] Basic Rust API with GraphQL
- [ ] SolidJS frontend with routing
- [ ] GitHub repo fetching
- [ ] Basic flake.nix generation

### Week 3-4: NixOS Integration
- [ ] Firecracker VM management
- [ ] Nix environment building
- [ ] VS Code web integration
- [ ] Terminal websocket connection

### Week 5-6: Core Features
- [ ] Branch/commit switching
- [ ] URL-based sharing
- [ ] Auto-detection improvements
- [ ] Error handling

### Week 7-8: Polish
- [ ] Loading states and progress
- [ ] Error recovery
- [ ] Performance optimization
- [ ] Basic monitoring

### Week 9-12: Launch Prep
- [ ] Deploy to production
- [ ] Stress testing
- [ ] Documentation
- [ ] Landing page polish

## Definition of "Done" for MVP

A user can:
1. Paste a GitHub URL for a Node.js project
2. Get a working development environment in under 60 seconds
3. Edit code and run commands
4. Share the environment with a colleague via URL
5. Switch to a 6-month-old branch and have it "just work"

That's it. Everything else comes after we validate the core concept.