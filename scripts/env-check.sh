#!/bin/bash

set -e

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    local cmd=$1
    local required=${2:-false}
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$cmd is installed"
        return 0
    else
        if [ "$required" = true ]; then
            log_error "$cmd is required but not installed"
            return 1
        else
            log_warning "$cmd is not installed"
            return 1
        fi
    fi
}

check_port() {
    local port=$1
    
    if command -v lsof &> /dev/null; then
        if lsof -i:"$port" &> /dev/null; then
            log_warning "Port $port is in use"
            return 1
        else
            log_success "Port $port is available"
            return 0
        fi
    else
        log_info "lsof not available, skipping port check for $port"
        return 0
    fi
}

check_docker_daemon() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log_success "Docker daemon is running"
        return 0
    else
        log_error "Docker daemon is not running"
        return 1
    fi
}

main() {
    log_info "🔍 Performing comprehensive environment check..."
    echo ""
    
    local all_good=true
    
    # Essential tools check
    log_info "Checking essential tools..."
    if ! check_command "docker" true; then
        all_good=false
    fi
    
    if ! check_command "docker-compose" true; then
        all_good=false
    fi
    
    # Docker daemon check
    if ! check_docker_daemon; then
        all_good=false
    fi
    echo ""
    
    # Optional tools check
    log_info "Checking optional tools..."
    check_command "node" false
    check_command "npm" false
    check_command "curl" false
    check_command "jq" false
    check_command "lsof" false
    check_command "git" false
    echo ""
    
    # Port availability check
    log_info "Checking port availability..."
    local ports=(3000 8000 8002 8003 27017 6379)
    local port_conflicts=false
    
    for port in "${ports[@]}"; do
        if ! check_port "$port"; then
            port_conflicts=true
        fi
    done
    
    if [ "$port_conflicts" = true ]; then
        log_warning "Some ports are in use - this may cause conflicts"
        echo ""
        if command -v lsof &> /dev/null; then
            log_info "💡 To check what's using the ports:"
            echo "  lsof -i :3000,8000,8002,8003,27017,6379"
        fi
    fi
    echo ""
    
    # Environment configuration check
    log_info "Checking environment configuration..."
    if [ -f .env ]; then
        log_success ".env file exists"
        
        # Check for required variables
        if grep -q "MONGO_ROOT_USERNAME" .env && [ -n "$(grep "MONGO_ROOT_USERNAME" .env | cut -d'=' -f2)" ]; then
            log_success "MongoDB username configured"
        else
            log_warning "MONGO_ROOT_USERNAME not properly set in .env"
        fi
        
        if grep -q "MONGO_ROOT_PASSWORD" .env && [ -n "$(grep "MONGO_ROOT_PASSWORD" .env | cut -d'=' -f2)" ]; then
            log_success "MongoDB password configured"
        else
            log_warning "MONGO_ROOT_PASSWORD not properly set in .env"
        fi
    else
        log_warning ".env file not found - will use default values"
        log_info "Run 'cp .env.example .env' to create environment file"
    fi
    echo ""
    
    # Final result
    if [ "$all_good" = true ]; then
        log_success "✅ Environment check passed!"
        echo ""
        echo "🚀 System is ready for development!"
        echo ""
        echo "Next steps:"
        echo "  make dev      # Start development environment"
        echo "  make health   # Check service health"
        echo "  make test     # Run all tests"
    else
        log_error "❌ Environment check failed!"
        echo ""
        echo "🔧 Please fix the issues above before proceeding"
        echo ""
        echo "Common solutions:"
        echo "  - Install Docker and Docker Compose"
        echo "  - Start Docker daemon"
        echo "  - Run 'make setup' to initialize project"
        exit 1
    fi
}

main "$@"
