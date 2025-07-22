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

# Service endpoints
declare -A SERVICES=(
    ["Frontend"]="http://localhost:3000"
    ["Text Service"]="http://localhost:8000/health"
    ["Dictionary Service"]="http://localhost:8002/health"
    ["Learning Service"]="http://localhost:8003/health"
)

check_service() {
    local name=$1
    local url=$2
    local timeout=${3:-10}
    
    if ! command -v curl >/dev/null 2>&1; then
        log_warning "curl not available, cannot check $name"
        return 1
    fi
    
    if curl -f -s --connect-timeout 5 --max-time "$timeout" "$url" > /dev/null 2>&1; then
        log_success "$name is healthy"
        return 0
    else
        log_error "$name is not responding"
        return 1
    fi
}

check_database_container() {
    local name=$1
    local container_name=$2
    
    if ! command -v docker >/dev/null 2>&1; then
        log_warning "Docker not available, cannot check $name"
        return 1
    fi
    
    if docker exec "$container_name" sh -c 'exit 0' > /dev/null 2>&1; then
        log_success "$name container is running"
        return 0
    else
        log_error "$name container is not running"
        return 1
    fi
}

main() {
    log_info "🏥 Starting health check for all services..."
    echo ""
    
    local all_healthy=true
    
    # Check Docker containers first
    log_info "Checking Docker containers..."
    if command -v docker >/dev/null 2>&1; then
        if command -v docker-compose >/dev/null 2>&1; then
            if ! docker-compose -f docker-compose.dev.yml ps --services --filter "status=running" > /dev/null 2>&1; then
                log_warning "Docker Compose not running in development mode"
            fi
        fi
    else
        log_warning "Docker not available"
    fi
    
    # Check databases
    log_info "Checking databases..."
    if command -v docker >/dev/null 2>&1; then
        if ! check_database_container "MongoDB" "vocab-mongodb-dev"; then
            all_healthy=false
        fi
        
        if ! check_database_container "Redis" "vocab-redis-dev"; then
            all_healthy=false
        fi
    fi
    
    echo ""
    
    # Check services
    log_info "Checking services..."
    for service in "${!SERVICES[@]}"; do
        if ! check_service "$service" "${SERVICES[$service]}"; then
            all_healthy=false
        fi
        sleep 1
    done
    
    echo ""
    
    # Container resource usage
    if command -v docker >/dev/null 2>&1; then
        log_info "Container resource usage:"
        if ! docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null; then
            log_warning "Could not retrieve container stats"
        fi
    fi
    
    echo ""
    
    # Overall result
    if [ "$all_healthy" = true ]; then
        log_success "✅ All services are healthy!"
        echo ""
        echo "🌐 Access points:"
        echo "  Frontend:           http://localhost:3000"
        echo "  Text Service:       http://localhost:8000"
        echo "  Dictionary Service: http://localhost:8002"
        echo "  Learning Service:   http://localhost:8003"
        exit 0
    else
        log_error "❌ Some services are unhealthy!"
        echo ""
        echo "💡 Troubleshooting:"
        echo "  make logs          # Check service logs"
        echo "  make dev           # Restart development environment"
        echo "  make clean && make dev  # Clean restart"
        exit 1
    fi
}

main "$@"
