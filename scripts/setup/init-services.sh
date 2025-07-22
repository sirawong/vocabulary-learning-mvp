# scripts/setup/init-services.sh - Service initialization
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"

main() {
    log_step "Initializing services..."
    
    cd "$PROJECT_ROOT"
    
    # Initialize each service
    log_info "Creating Text Service..."
    "$SCRIPT_DIR/services/create-text-service.sh"
    
    log_info "Creating Dictionary Service..."
    "$SCRIPT_DIR/services/create-dictionary-service.sh"
    
    log_info "Creating Learning Service..."
    "$SCRIPT_DIR/services/create-learning-service.sh"
    
    log_info "Creating Frontend..."
    "$SCRIPT_DIR/services/create-frontend.sh"
    
    log_info "Creating MongoDB initialization..."
    "$SCRIPT_DIR/database/create-mongo-init.sh"
    
    log_success "Services initialized"
}

main "$@"
