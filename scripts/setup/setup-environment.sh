# scripts/setup/setup-environment.sh - Environment configuration
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"
source "$SCRIPT_DIR/../utils/file-helpers.sh"

main() {
    log_step "Setting up environment configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Create .env.example
    log_info "Creating environment template..."
    cat > .env.example << 'EOF'
# Database Configuration
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=password123
MONGO_DATABASE=vocabulary_db

# Redis Configuration
REDIS_URL=redis://localhost:6379

# API Keys
DICTIONARY_API_KEY=your_dictionary_api_key_here

# Service URLs (for production)
TEXT_SERVICE_URL=http://localhost:8000
DICTIONARY_SERVICE_URL=http://localhost:8002
LEARNING_SERVICE_URL=http://localhost:8003

# Frontend URLs
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_DICTIONARY_URL=http://localhost:8002
NEXT_PUBLIC_LEARNING_URL=http://localhost:8003

# Development
DEBUG=false
NODE_ENV=development
EOF

    # Copy to actual .env if it doesn't exist
    if [ ! -f .env ]; then
        cp .env.example .env
        log_info "Created .env file from template"
    else
        log_info ".env file already exists, keeping existing configuration"
    fi
    
    # Create .gitignore
    log_info "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Production builds
dist/
build/
.next/

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Coverage
coverage/

# Temporary files
tmp/
temp/

# MongoDB data
data/
EOF

    log_success "Environment configuration created"
}

main "$@"

# ---
