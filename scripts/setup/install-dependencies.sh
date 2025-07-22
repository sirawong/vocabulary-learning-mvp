# scripts/setup/install-dependencies.sh - Dependencies Installation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"

main() {
    log_step "Installing dependencies for all services..."
    
    cd "$PROJECT_ROOT"
    
    # Check if npm is available locally
    if command -v npm &> /dev/null; then
        log_info "npm found locally, installing dependencies..."
        
        # Install frontend dependencies
        if [ -f frontend/package.json ]; then
            log_info "Installing frontend dependencies..."
            cd frontend && npm install && cd ..
            show_progress 1 4 "Frontend dependencies installed"
        fi
        
        # Install service dependencies
        local services=("text-service" "dictionary-service" "learning-service")
        local current=2
        
        for service in "${services[@]}"; do
            if [ -f "services/$service/package.json" ]; then
                log_info "Installing $service dependencies..."
                cd "services/$service" && npm install && cd ../..
                show_progress $current 4 "$service dependencies installed"
                ((current++))
            fi
        done
        
        log_success "All dependencies installed locally"
    else
        log_warning "npm not found locally - dependencies will be installed in Docker containers"
        log_info "Dependencies will be installed when containers are built"
    fi
}

main "$@"

# ---
