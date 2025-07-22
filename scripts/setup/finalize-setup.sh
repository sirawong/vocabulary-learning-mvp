# scripts/setup/finalize-setup.sh - Final Setup Steps
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"

main() {
    log_step "Performing final setup steps..."
    
    cd "$PROJECT_ROOT"
    
    # Make all scripts executable
    log_info "Making scripts executable..."
    find scripts -name "*.sh" -type f -exec chmod +x {} \;
    
    # Create any missing directories
    log_info "Ensuring all directories exist..."
    mkdir -p logs data tmp
    
    # Create .dockerignore files for services
    log_info "Creating .dockerignore files..."
    local dockerignore_content="node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist
coverage
.DS_Store
*.log
.git
.gitignore
README.md
.eslintrc.js
.prettierrc"

    echo "$dockerignore_content" > services/text-service/.dockerignore
    echo "$dockerignore_content" > services/dictionary-service/.dockerignore
    echo "$dockerignore_content" > services/learning-service/.dockerignore
    echo "$dockerignore_content" > frontend/.dockerignore
    
    # Update timestamps in documentation
    log_info "Updating documentation timestamps..."
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/Last Updated: \$(date)/Last Updated: $current_date/" PROGRESS.md
        find services -name "STATUS.md" -exec sed -i '' "s/Last Updated: \\\$(date)/Last Updated: $current_date/" {} \;
    else
        # Linux
        sed -i "s/Last Updated: \$(date)/Last Updated: $current_date/" PROGRESS.md
        find services -name "STATUS.md" -exec sed -i "s/Last Updated: \\\$(date)/Last Updated: $current_date/" {} \;
    fi
    
    # Validate setup
    log_info "Validating setup..."
    
    # Check that all required files exist
    local required_files=(
        "Makefile"
        "docker-compose.yml"
        "docker-compose.dev.yml"
        ".env.example"
        "README.md"
        "SETUP.md"
        "PROGRESS.md"
        "services/text-service/package.json"
        "services/dictionary-service/package.json"
        "services/learning-service/package.json"
        "frontend/package.json"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Check that all required scripts exist
    local required_scripts=(
        "scripts/health-check.sh"
        "scripts/test.sh"
        "scripts/clean.sh"
        "scripts/env-check.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [ ! -f "$script" ]; then
            log_error "Required script missing: $script"
            exit 1
        fi
    done
    
    log_success "Setup validation completed"
    
    # Create setup completion marker
    echo "Setup completed on: $current_date" > .setup-complete
    
    log_success "Final setup steps completed"
}

main "$@"
