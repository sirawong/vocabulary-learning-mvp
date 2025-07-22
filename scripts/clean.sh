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

cleanup_containers() {
    log_info "Stopping and removing containers..."
    
    # Stop all composer services
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    docker-compose down 2>/dev/null || true
    
    # Remove vocabulary-related containers
    local containers=$(docker ps -a --filter "name=vocab-" --format "{{.ID}}" 2>/dev/null || true)
    if [ -n "$containers" ]; then
        echo "$containers" | xargs docker rm -f
        log_success "Removed vocabulary containers"
    fi
}

cleanup_images() {
    log_info "Removing vocabulary-related images..."
    
    # Remove project-specific images
    local images=$(docker images --filter "reference=vocabulary-learning-mvp*" -q 2>/dev/null || true)
    if [ -n "$images" ]; then
        echo "$images" | xargs docker rmi -f
    fi
    
    # Remove service images
    for service in text-service dictionary-service learning-service vocabulary-frontend; do
        local service_images=$(docker images --filter "reference=*$service*" -q 2>/dev/null || true)
        if [ -n "$service_images" ]; then
            echo "$service_images" | xargs docker rmi -f
        fi
    done
    
    log_success "Removed vocabulary images"
}

cleanup_volumes() {
    log_info "Cleaning up volumes..."
    
    # Remove vocabulary volumes
    local volumes=$(docker volume ls --filter "name=vocabulary" --format "{{.Name}}" 2>/dev/null || true)
    if [ -n "$volumes" ]; then
        echo "$volumes" | xargs docker volume rm 2>/dev/null || true
    fi
    
    log_success "Cleaned up volumes"
}

main() {
    log_info "🧹 Starting cleanup process..."
    echo ""
    
    if ! command -v docker >/dev/null 2>&1; then
        log_warning "Docker not available, cannot perform cleanup"
        exit 1
    fi
    
    cleanup_containers
    cleanup_images
    
    # Only clean volumes if requested
    if [ "${1:-}" = "--volumes" ] || [ "${1:-}" = "-v" ]; then
        cleanup_volumes
    fi
    
    # Clean up dangling resources
    log_info "System cleanup..."
    docker container prune -f >/dev/null 2>&1 || true
    docker image prune -f >/dev/null 2>&1 || true
    log_success "System cleanup completed"
    
    echo ""
    log_success "✅ Cleanup completed!"
    
    if [ "${1:-}" != "--volumes" ] && [ "${1:-}" != "-v" ]; then
        echo ""
        log_info "💡 To also remove volumes (database data), run:"
        echo "  make clean-hard"
        echo "  # or"
        echo "  ./scripts/clean.sh --volumes"
    fi
}

main "$@"
