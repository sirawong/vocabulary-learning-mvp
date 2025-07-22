#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions with fallback
if [ -f "$SCRIPT_DIR/utils/logger.sh" ]; then
    source "$SCRIPT_DIR/utils/logger.sh"
else
    # Fallback logging functions
    log_info() {
        echo -e "\033[0;34m[INFO]\033[0m $1"
    }
    
    log_success() {
        echo -e "\033[0;32m[SUCCESS]\033[0m $1"
    }
    
    log_error() {
        echo -e "\033[0;31m[ERROR]\033[0m $1"
    }
    
    log_warning() {
        echo -e "\033[1;33m[WARNING]\033[0m $1"
    }
fi

update_timestamp() {
    local file=$1
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ ! -f "$file" ]; then
        log_warning "File not found: $file"
        return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/Last Updated:.*/Last Updated: $current_date/" "$file"
    else
        # Linux
        sed -i "s/Last Updated:.*/Last Updated: $current_date/" "$file"
    fi
}

check_service_status() {
    local service_name=$1
    local port=$2
    
    if command -v curl >/dev/null 2>&1; then
        if curl -f -s --connect-timeout 5 --max-time 10 "http://localhost:$port/health" > /dev/null 2>&1; then
            echo "✅ $service_name is healthy"
            return 0
        else
            echo "❌ $service_name is not responding"
            return 1
        fi
    else
        echo "⚠️  curl not available, cannot check $service_name"
        return 1
    fi
}

main() {
    log_info "📝 Updating progress tracking..."
    
    cd "$PROJECT_ROOT" || {
        log_error "Cannot change to project root: $PROJECT_ROOT"
        exit 1
    }
    
    # Update main progress file
    if [ -f "PROGRESS.md" ]; then
        update_timestamp "PROGRESS.md"
        log_success "Updated PROGRESS.md"
    else
        log_warning "PROGRESS.md not found"
    fi
    
    # Update service status files
    for service in text-service dictionary-service learning-service; do
        if [ -f "services/$service/STATUS.md" ]; then
            update_timestamp "services/$service/STATUS.md"
            log_success "Updated $service/STATUS.md"
        else
            log_warning "STATUS.md not found for $service"
        fi
    done
    
    echo ""
    log_info "🏥 Checking current service status..."
    
    # Check services if they're running
    check_service_status "Text Service" "8000"
    check_service_status "Dictionary Service" "8002"
    check_service_status "Learning Service" "8003"
    
    # Check frontend
    if command -v curl >/dev/null 2>&1; then
        if curl -f -s --connect-timeout 5 --max-time 10 "http://localhost:3000" > /dev/null 2>&1; then
            echo "✅ Frontend is running"
        else
            echo "❌ Frontend is not responding"
        fi
    else
        echo "⚠️  curl not available, cannot check Frontend"
    fi
    
    # Check containers
    echo ""
    log_info "🐳 Container status:"
    if command -v docker >/dev/null 2>&1; then
        local containers=$(docker ps --filter "name=vocab-" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null)
        if [ -n "$containers" ]; then
            echo "$containers"
        else
            echo "No vocabulary containers running"
        fi
    else
        echo "Docker not available"
    fi
    
    echo ""
    log_success "Progress tracking updated!"
}

main "$@"
