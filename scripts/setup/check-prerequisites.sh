# scripts/setup/check-prerequisites.sh - Prerequisites validation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logger.sh"
source "$SCRIPT_DIR/../utils/checks.sh"

main() {
    log_step "Checking prerequisites..."
    
    local all_good=true
    
    # Required tools
    log_info "Checking required tools..."
    if ! check_command "docker" true; then
        all_good=false
    fi
    
    if ! check_command "docker-compose" true; then
        all_good=false
    fi
    
    # Check Docker daemon
    if ! check_docker_daemon; then
        all_good=false
    fi
    
    # Optional tools
    log_info "Checking optional tools..."
    check_command "node" false
    check_command "npm" false
    check_command "curl" false
    check_command "jq" false
    check_command "lsof" false
    
    # Check ports
    log_info "Checking port availability..."
    for port in 3000 8000 8002 8003 27017 6379; do
        check_port "$port" || true  # Don't fail on port conflicts
    done
    
    # Check disk space
    check_disk_space 3  # Minimum 3GB
    
    if [ "$all_good" != true ]; then
        log_error "Prerequisites check failed"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

main "$@"

# ---
