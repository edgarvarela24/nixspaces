# NixSpaces Development Commands
# Run 'just' to see available commands

# Default command - show help
default:
    @just --list

# Development commands
dev: db-start
    #!/usr/bin/env bash
    echo "🚀 Starting development environment..."
    # Kill any existing tmux session
    tmux kill-session -t nixspaces 2>/dev/null || true
    # Run migrations if any exist
    if [ -d backend/migrations ] && [ "$(ls -A backend/migrations)" ]; then
        cd backend && sqlx migrate run && cd ..
    fi
    # Start backend and frontend in tmux
    tmux new-session -d -s nixspaces
    tmux send-keys -t nixspaces:0 'cd backend && cargo watch -x run' C-m
    tmux split-window -h -t nixspaces:0
    tmux send-keys -t nixspaces:0 'cd frontend && pnpm dev' C-m
    tmux attach -t nixspaces

# Testing commands
test:
    echo "🧪 Running all tests..."
    cd backend && cargo nextest run

# Run specific backend tests
test-backend *ARGS:
    cd backend && cargo nextest run {{ARGS}}

# Quick test shortcut
t *ARGS:
    cd backend && cargo nextest run {{ARGS}}

# Format all code
fmt:
    echo "✨ Formatting code..."
    cd backend && cargo fmt --all
    nixpkgs-fmt .

# Run linters
lint:
    echo "🔍 Running linters..."
    cd backend && cargo clippy --all-targets --all-features -- -D warnings

# Quick check
c:
    cd backend && cargo check

# Quick run
r *ARGS:
    cd backend && cargo run {{ARGS}}

# Database commands
db-start:
    #!/usr/bin/env bash
    if pg_isready -q 2>/dev/null; then
        echo "✅ PostgreSQL is already running"
    else
        echo "🚀 Starting PostgreSQL..."
        pg_ctl start -D .pgdata -l .pgdata/logfile
        echo "⏳ Waiting for PostgreSQL to be ready..."
        while ! pg_isready -q; do sleep 1; done
        echo "✅ PostgreSQL started successfully"
    fi

db-stop:
    echo "🛑 Stopping PostgreSQL..."
    pg_ctl stop -D .pgdata -m fast

db-init:
    #!/usr/bin/env bash
    if [ -d .pgdata ]; then
        echo "❌ PostgreSQL data directory already exists. Use 'just db-reset' to reinitialize."
        exit 1
    fi
    echo "🔧 Initializing PostgreSQL..."
    initdb -D .pgdata -U nixspaces --auth-local=trust --auth-host=md5
    echo "🚀 Starting PostgreSQL..."
    pg_ctl start -D .pgdata -l .pgdata/logfile
    sleep 2
    echo "📝 Creating databases..."
    createdb nixspaces_dev
    createdb nixspaces_test
    echo "✅ PostgreSQL initialized successfully"

db-reset:
    #!/usr/bin/env bash
    echo "⚠️  Resetting PostgreSQL (this will delete all data)..."
    pg_ctl stop -D .pgdata -m immediate 2>/dev/null || true
    rm -rf .pgdata
    echo "🔧 Reinitializing..."
    initdb -D .pgdata -U nixspaces --auth-local=trust --auth-host=md5
    pg_ctl start -D .pgdata -l .pgdata/logfile
    sleep 2
    createdb nixspaces_dev
    createdb nixspaces_test
    echo "✅ PostgreSQL reset successfully"

db-cli:
    pgcli $DATABASE_URL || psql $DATABASE_URL

db-status:
    #!/usr/bin/env bash
    if pg_isready -q 2>/dev/null; then
        echo "✅ PostgreSQL is running"
        psql -U nixspaces -d postgres -c "\l" | grep nixspaces || true
    else
        echo "❌ PostgreSQL is not running"
    fi

# Migration commands
migrate-new NAME:
    cd backend && sqlx migrate add {{NAME}}
    echo "✅ Created new migration: {{NAME}}"

migrate-run:
    echo "🚀 Running migrations..."
    cd backend && sqlx migrate run
    echo "✅ Migrations completed"

migrate-revert:
    echo "↩️  Reverting last migration..."
    cd backend && sqlx migrate revert

migrate-info:
    cd backend && sqlx migrate info

# Useful aliases
alias m := migrate-run
alias mn := migrate-new