# scripts/setup/create-structure.sh - Directory structure creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"
source "$SCRIPT_DIR/../utils/checks.sh"

main() {
    log_step "Creating project directory structure..."
    
    cd "$PROJECT_ROOT"
    
    # Main service directories
    log_info "Creating service directories..."
    local services=("text-service" "dictionary-service" "learning-service")
    
    for service in "${services[@]}"; do
        log_debug "Creating $service structure..."
        ensure_directory "services/$service/src/controllers"
        ensure_directory "services/$service/src/services"
        ensure_directory "services/$service/src/models"
        ensure_directory "services/$service/src/utils"
        ensure_directory "services/$service/src/middleware"
        ensure_directory "services/$service/tests"
    done
    
    # Frontend directories
    log_info "Creating frontend directories..."
    ensure_directory "frontend/src/app"
    ensure_directory "frontend/src/components"
    ensure_directory "frontend/src/lib"
    ensure_directory "frontend/src/types"
    ensure_directory "frontend/public"
    
    # Shared directories
    log_info "Creating shared directories..."
    ensure_directory "shared/types"
    ensure_directory "shared/utils"
    
    # Scripts directories
    log_info "Creating scripts directories..."
    ensure_directory "scripts/setup"
    ensure_directory "scripts/utils"
    ensure_directory "scripts/templates"
    
    log_success "Directory structure created"
}

main "$@"

# ---
