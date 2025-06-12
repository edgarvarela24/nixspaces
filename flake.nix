{
  description = "NixSpaces - Branch Everything Development Environment Platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
        };

        # Crane for Rust build management
        craneLib = crane.lib.${system}.overrideToolchain rustToolchain;

        # Backend dependencies
        backendBuildInputs = with pkgs; [
          pkg-config
          openssl
          postgresql
          protobuf # For gRPC if needed
        ];

        # Frontend tooling
        frontendTools = with pkgs; [
          nodejs_20
          nodePackages.pnpm
          nodePackages.typescript
          nodePackages.typescript-language-server
          nodePackages.prettier
          nodePackages.eslint
          bun # Alternative JS runtime for testing
        ];

        # Development tools
        devTools = with pkgs; [
          # Version control
          git
          gh
          git-lfs
          delta # Better git diff
          
          # Database
          postgresql_15
          pgcli
          atlas # Schema management
          dbmate # Migration tool
          
          # Container/VM tools
          firecracker
          firectl
          cni-plugins
          buildah # OCI image building
          skopeo # OCI image operations
          umoci # OCI image manipulation
          runc # Container runtime
          
          # GraphQL
          graphql-playground
          apollo-rover # GraphQL schema management
          
          # Nix tools
          nil # Nix LSP
          nixpkgs-fmt
          alejandra # Alternative Nix formatter
          statix # Nix linter
          deadnix # Find dead Nix code
          nix-tree # Visualize dependencies
          nix-diff # Compare derivations
          nix-prefetch-git
          nix-output-monitor # Better nix build output
          nvd # Nix version diff
          cachix
          
          # General development
          curl
          jq
          yq # YAML processor
          ripgrep
          fd
          bat
          eza # Better ls
          httpie
          xh # Faster httpie
          watchexec
          entr # Run commands on file change
          tmux
          tmuxp # Tmux session manager
          direnv # Per-directory environments
          just # Command runner
          mkcert # Local HTTPS certificates
          
          # Testing
          k6 # Load testing
          drill # HTTP load testing
          vegeta # HTTP load testing
          
          # Documentation
          mdbook
          plantuml # Diagram generation
          graphviz # Graph visualization
          
          # Observability
          vector # Logs and metrics
          prometheus
          grafana
          
          # Security
          trivy # Vulnerability scanner
          grype # Container vulnerability scanner
          syft # SBOM generator
          
          # Performance
          hyperfine # Command-line benchmarking
          flamegraph # Profiling visualization
          heaptrack # Memory profiler
          
          # Cloud/Infrastructure
          awscli2 # For S3 compatibility
          terraform # Infrastructure as code
          
          # Development utilities
          tokei # Code statistics
          scc # Code counter
          gitleaks # Secret scanning
          pre-commit # Git hooks
        ];

        # Rust backend package (to be implemented)
        nixspacesBackend = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./backend);
          buildInputs = backendBuildInputs;
          cargoExtraArgs = "--workspace";
        };

        # Pre-commit hooks
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Nix
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            
            # Rust
            rustfmt.enable = true;
            clippy = {
              enable = true;
              entry = "cargo clippy --all-targets --all-features -- -D warnings";
            };
            
            # Frontend
            prettier = {
              enable = true;
              types = [ "javascript" "typescript" "css" "html" "json" "markdown" "yaml" ];
            };
            eslint = {
              enable = true;
              types = [ "javascript" "typescript" ];
            };
            
            # Security
            gitleaks = {
              enable = true;
              name = "gitleaks";
              entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
              pass_filenames = false;
            };
            
            # General
            end-of-file-fixer.enable = true;
            trailing-whitespace.enable = true;
            check-added-large-files.enable = true;
          };
        };

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            bacon # Better cargo-watch
            cargo-watch
            cargo-nextest # Better test runner
            cargo-edit
            cargo-audit
            cargo-deny # Supply chain security
            cargo-outdated
            cargo-tarpaulin # Code coverage
            cargo-llvm-cov # LLVM-based coverage
            cargo-machete # Find unused dependencies
            cargo-release # Release automation
            cargo-generate # Project templates
            sqlx-cli # Database migrations
            sccache # Compilation cache
            just # Command runner for developer tasks
          ] ++ backendBuildInputs ++ frontendTools ++ devTools;

          shellHook = ''
            echo "🚀 NixSpaces Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Rust: $(rustc --version)"
            echo "Node: $(node --version)"
            echo "PostgreSQL: $(postgres --version)"
            echo "Nix: $(nix --version)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Available commands:"
            echo "  nix run .#dev       - Start development environment"
            echo "  nix run .#test      - Run all tests"
            echo "  nix run .#fmt       - Format all code"
            echo "  nix run .#lint      - Run all linters"
            echo "  nix run .#db        - Database management"
            echo "  nix run .#migrate   - Create new migration"
            echo "  nix run .#gql       - GraphQL tools"
            echo "  nix run .#sec       - Security checks"
            echo "  nix run .#bench     - Run benchmarks"
            echo "  nix run .#docs      - Build documentation"
            echo "  nix flake check     - Run all checks"
            echo ""
            
            # Create .env if it doesn't exist
            if [ ! -f .env ]; then
              echo "Creating .env file..."
              cat > .env <<EOF
# Database
DATABASE_URL=postgresql://nixspaces:nixspaces@localhost/nixspaces_dev
DATABASE_TEST_URL=postgresql://nixspaces:nixspaces@localhost/nixspaces_test

# Rust
RUST_LOG=debug,sqlx=warn,tower_http=debug
RUST_BACKTRACE=1

# API
API_HOST=127.0.0.1
API_PORT=8080
GRAPHQL_PATH=/graphql
GRAPHQL_PLAYGROUND=true

# Frontend
VITE_API_URL=http://localhost:8080/graphql
VITE_WS_URL=ws://localhost:8080/ws

# Nix
NIX_STORE_DIR=/nix/store
NIX_BUILD_CORES=4

# Firecracker
FIRECRACKER_BIN=${pkgs.firecracker}/bin/firecracker
FIRECTL_BIN=${pkgs.firectl}/bin/firectl

# Security
JWT_SECRET=dev-secret-change-in-production
SESSION_SECRET=dev-session-secret-change-in-production

# Development
HOT_RELOAD=true
PRETTIER_IGNORE_PATH=.prettierignore
EOF
            fi
            
            # Set up PostgreSQL data directory
            export PGDATA=$PWD/.pgdata
            export PGHOST=$PWD
            export PGUSER=nixspaces
            export DATABASE_URL=postgresql://nixspaces:nixspaces@localhost/nixspaces_dev
            
            # Rust optimizations
            export RUSTFLAGS="-C link-arg=-fuse-ld=lld"
            export CARGO_TARGET_DIR=$PWD/target
            
            # Enable sccache
            export RUSTC_WRAPPER=${pkgs.sccache}/bin/sccache
            export SCCACHE_DIR=$PWD/.sccache
            
            # Pre-commit hooks
            ${pre-commit-check.shellHook}
            
            # Create directories if they don't exist
            mkdir -p .pgdata .sccache backend/migrations frontend/src
            
            # Git configuration for better diffs
            git config diff.algorithm histogram 2>/dev/null || true
            git config merge.conflictstyle diff3 2>/dev/null || true
            
            # Check if tmux session exists
            if tmux has-session -t nixspaces 2>/dev/null; then
              echo "📌 Existing tmux session 'nixspaces' found. Attach with: tmux attach -t nixspaces"
            fi
          '';

          # Environment variables
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_LOG = "debug";
          RUST_BACKTRACE = 1;
        };

        # Useful scripts/apps
        apps = {
          # Development server (runs both backend and frontend)
          dev = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev" ''
              echo "Starting NixSpaces development environment..."
              
              # Start PostgreSQL if not running
              if ! pg_isready -q; then
                echo "Starting PostgreSQL..."
                pg_ctl start -D .pgdata -l .pgdata/logfile
                sleep 2
                createdb nixspaces_dev 2>/dev/null || true
              fi
              
              # Run migrations
              if [ -d backend/migrations ]; then
                cd backend && sqlx migrate run && cd ..
              fi
              
              # Start backend and frontend in parallel
              ${pkgs.tmux}/bin/tmux new-session -d -s nixspaces
              ${pkgs.tmux}/bin/tmux send-keys -t nixspaces:0 'cd backend && cargo watch -x run' C-m
              ${pkgs.tmux}/bin/tmux split-window -h -t nixspaces:0
              ${pkgs.tmux}/bin/tmux send-keys -t nixspaces:0 'cd frontend && pnpm dev' C-m
              ${pkgs.tmux}/bin/tmux attach -t nixspaces
            '';
          };

          # Run all tests
          test = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "test" ''
              echo "Running all tests..."
              
              # Backend tests
              echo "Backend tests:"
              cd backend && cargo nextest run && cd ..
              
              # Frontend tests
              echo "Frontend tests:"
              cd frontend && pnpm test && cd ..
            '';
          };

          # Format all code
          fmt = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "fmt" ''
              echo "Formatting code..."
              
              # Rust
              cargo fmt --all
              
              # Nix
              nixpkgs-fmt .
              
              # Frontend
              cd frontend && pnpm format && cd ..
            '';
          };

          # Run all linters
          lint = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "lint" ''
              echo "Running linters..."
              
              # Rust
              cargo clippy --all-targets --all-features -- -D warnings
              
              # Frontend
              cd frontend && pnpm lint && cd ..
            '';
          };

          # Database management
          db = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "db" ''
              set -euo pipefail
              
              case "''${1:-help}" in
                start)
                  if pg_isready -q 2>/dev/null; then
                    echo "PostgreSQL is already running"
                  else
                    echo "Starting PostgreSQL..."
                    pg_ctl start -D .pgdata -l .pgdata/logfile
                    echo "Waiting for PostgreSQL to be ready..."
                    while ! pg_isready -q; do sleep 1; done
                    echo "PostgreSQL started successfully"
                  fi
                  ;;
                stop)
                  echo "Stopping PostgreSQL..."
                  pg_ctl stop -D .pgdata -m fast
                  ;;
                init)
                  if [ -d .pgdata ]; then
                    echo "PostgreSQL data directory already exists. Use 'reset' to reinitialize."
                    exit 1
                  fi
                  echo "Initializing PostgreSQL..."
                  initdb -D .pgdata -U nixspaces --auth-local=trust --auth-host=md5
                  echo "Starting PostgreSQL..."
                  pg_ctl start -D .pgdata -l .pgdata/logfile
                  sleep 2
                  echo "Creating databases..."
                  createdb nixspaces_dev
                  createdb nixspaces_test
                  echo "PostgreSQL initialized successfully"
                  ;;
                reset)
                  echo "Resetting PostgreSQL..."
                  pg_ctl stop -D .pgdata -m immediate 2>/dev/null || true
                  rm -rf .pgdata
                  echo "Reinitializing..."
                  initdb -D .pgdata -U nixspaces --auth-local=trust --auth-host=md5
                  pg_ctl start -D .pgdata -l .pgdata/logfile
                  sleep 2
                  createdb nixspaces_dev
                  createdb nixspaces_test
                  echo "PostgreSQL reset successfully"
                  ;;
                cli)
                  pgcli $DATABASE_URL
                  ;;
                status)
                  if pg_isready -q 2>/dev/null; then
                    echo "PostgreSQL is running"
                    psql -U nixspaces -d postgres -c "\l" | grep nixspaces || true
                  else
                    echo "PostgreSQL is not running"
                  fi
                  ;;
                *)
                  echo "Usage: nix run .#db -- {start|stop|init|reset|cli|status}"
                  echo ""
                  echo "Commands:"
                  echo "  start  - Start PostgreSQL server"
                  echo "  stop   - Stop PostgreSQL server"
                  echo "  init   - Initialize PostgreSQL (first time setup)"
                  echo "  reset  - Reset PostgreSQL (delete all data)"
                  echo "  cli    - Open PostgreSQL CLI"
                  echo "  status - Check PostgreSQL status"
                  ;;
              esac
            '';
          };

          # Migration management
          migrate = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "migrate" ''
              set -euo pipefail
              
              case "''${1:-help}" in
                new)
                  if [ -z "''${2:-}" ]; then
                    echo "Error: Migration name required"
                    echo "Usage: nix run .#migrate -- new <migration_name>"
                    exit 1
                  fi
                  cd backend
                  sqlx migrate add "$2"
                  echo "Created new migration: $2"
                  ;;
                run)
                  echo "Running migrations..."
                  cd backend
                  sqlx migrate run
                  echo "Migrations completed"
                  ;;
                revert)
                  echo "Reverting last migration..."
                  cd backend
                  sqlx migrate revert
                  ;;
                info)
                  cd backend
                  sqlx migrate info
                  ;;
                *)
                  echo "Usage: nix run .#migrate -- {new|run|revert|info}"
                  echo ""
                  echo "Commands:"
                  echo "  new <name>  - Create new migration"
                  echo "  run         - Run pending migrations"
                  echo "  revert      - Revert last migration"
                  echo "  info        - Show migration status"
                  ;;
              esac
            '';
          };

          # GraphQL tools
          gql = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "gql" ''
              set -euo pipefail
              
              case "''${1:-help}" in
                playground)
                  echo "Opening GraphQL playground at http://localhost:8080/graphql"
                  open http://localhost:8080/graphql || xdg-open http://localhost:8080/graphql
                  ;;
                schema)
                  if [ -f backend/schema.graphql ]; then
                    cat backend/schema.graphql
                  else
                    echo "Schema file not found. Run the backend first to generate it."
                  fi
                  ;;
                codegen)
                  echo "Running GraphQL code generation..."
                  cd frontend
                  pnpm graphql-codegen
                  ;;
                *)
                  echo "Usage: nix run .#gql -- {playground|schema|codegen}"
                  echo ""
                  echo "Commands:"
                  echo "  playground - Open GraphQL playground"
                  echo "  schema     - Display GraphQL schema"
                  echo "  codegen    - Generate TypeScript types from schema"
                  ;;
              esac
            '';
          };

          # Security checks
          sec = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "sec" ''
              set -euo pipefail
              
              echo "🔒 Running security checks..."
              echo ""
              
              # Rust security audit
              echo "📦 Checking Rust dependencies..."
              cd backend
              cargo audit || true
              cargo deny check || true
              cd ..
              echo ""
              
              # Frontend vulnerability scan
              echo "📦 Checking JavaScript dependencies..."
              cd frontend
              pnpm audit || true
              cd ..
              echo ""
              
              # Container/image scanning
              if [ -f Dockerfile ]; then
                echo "🐳 Scanning container image..."
                trivy image --severity HIGH,CRITICAL . || true
              fi
              echo ""
              
              # Secret scanning
              echo "🔑 Scanning for secrets..."
              gitleaks detect --verbose || true
              echo ""
              
              echo "✅ Security checks completed"
            '';
          };

          # Benchmarking
          bench = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "bench" ''
              set -euo pipefail
              
              case "''${1:-all}" in
                rust)
                  echo "Running Rust benchmarks..."
                  cd backend
                  cargo bench
                  ;;
                api)
                  echo "Running API load tests..."
                  k6 run tests/load/api.js
                  ;;
                db)
                  echo "Running database benchmarks..."
                  cd backend
                  cargo bench --bench db_bench
                  ;;
                all)
                  echo "Running all benchmarks..."
                  cd backend
                  cargo bench
                  cd ..
                  if [ -f tests/load/api.js ]; then
                    k6 run tests/load/api.js
                  fi
                  ;;
                *)
                  echo "Usage: nix run .#bench -- {rust|api|db|all}"
                  ;;
              esac
            '';
          };

          # Documentation
          docs = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "docs" ''
              set -euo pipefail
              
              case "''${1:-build}" in
                build)
                  echo "Building documentation..."
                  # Rust docs
                  cd backend
                  cargo doc --no-deps --all-features
                  cd ..
                  # MDBook docs
                  if [ -d docs ]; then
                    mdbook build docs
                  fi
                  echo "Documentation built successfully"
                  ;;
                serve)
                  echo "Serving documentation..."
                  cd backend
                  cargo doc --no-deps --all-features --open &
                  cd ..
                  if [ -d docs ]; then
                    mdbook serve docs &
                  fi
                  wait
                  ;;
                *)
                  echo "Usage: nix run .#docs -- {build|serve}"
                  ;;
              esac
            '';
          };
        };

        # Flake checks for CI
        checks = {
          # Format check
          format = pkgs.runCommand "format-check" {} ''
            cd ${./.}
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check . || exit 1
            ${pkgs.cargo}/bin/cargo fmt --check --manifest-path backend/Cargo.toml || exit 1
            touch $out
          '';
          
          # Lint check
          lint = pkgs.runCommand "lint-check" {} ''
            cd ${./.}
            ${pkgs.statix}/bin/statix check . || exit 1
            ${pkgs.deadnix}/bin/deadnix check . || exit 1
            touch $out
          '';
          
          # Pre-commit check
          pre-commit = pre-commit-check;
        };

        # Additional development shells
        devShells = {
          # Minimal shell for CI
          ci = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustToolchain
              cargo-nextest
              cargo-llvm-cov
              nodejs_20
              nodePackages.pnpm
              postgresql_15
            ] ++ backendBuildInputs;
          };
          
          # Documentation shell
          docs = pkgs.mkShell {
            buildInputs = with pkgs; [
              mdbook
              mdbook-mermaid
              mdbook-plantuml
              plantuml
              graphviz
            ];
          };
        };

        # Packages for production
        packages = {
          # Backend package
          backend = nixspacesBackend;
          
          # Docker image
          docker = pkgs.dockerTools.buildImage {
            name = "nixspaces";
            tag = "latest";
            contents = [ nixspacesBackend ];
            config = {
              Cmd = [ "${nixspacesBackend}/bin/nixspaces" ];
              ExposedPorts = {
                "8080/tcp" = {};
              };
            };
          };
        };
      });
}