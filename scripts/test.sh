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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

main() {
    log_info "🧪 Running all tests and validations..."
    
    local all_passed=true
    
    # Environment check
    log_info "Step 1: Environment validation..."
    if ./scripts/env-check.sh; then
        log_success "Environment check passed"
    else
        log_error "Environment check failed"
        all_passed=false
    fi
    echo ""
    
    # Health check
    log_info "Step 2: Service health checks..."
    if ./scripts/health-check.sh; then
        log_success "Health checks passed"
    else
        log_error "Health checks failed"
        all_passed=false
    fi
    echo ""
    
    # TypeScript checks (if npm is available)
    log_info "Step 3: TypeScript validation..."
    if command -v npm >/dev/null 2>&1; then
        if make type-check; then
            log_success "TypeScript checks passed"
        else
            log_error "TypeScript checks failed"
            all_passed=false
        fi
    else
        log_info "npm not available, skipping TypeScript checks"
    fi
    echo ""
    
    # API endpoint tests
    log_info "Step 4: Basic API tests..."
    local api_passed=true
    
    # Test each service endpoint
    services=("8000:text-service" "8002:dictionary-service" "8003:learning-service")
    
    for service_info in "${services[@]}"; do
        port="${service_info%%:*}"
        name="${service_info##*:}"
        
        if command -v curl >/dev/null 2>&1; then
            if curl -f -s --max-time 10 "http://localhost:$port/health" > /dev/null; then
                log_success "$name API test passed"
            else
                log_error "$name API test failed"
                api_passed=false
            fi
        else
            log_info "curl not available, skipping $name API test"
        fi
    done
    
    # Test frontend
    if command -v curl >/dev/null 2>&1; then
        if curl -f -s --max-time 10 "http://localhost:3000" > /dev/null; then
            log_success "Frontend test passed"
        else
            log_error "Frontend test failed"
            api_passed=false
        fi
    else
        log_info "curl not available, skipping Frontend test"
    fi
    
    if [ "$api_passed" = true ]; then
        log_success "API tests passed"
    else
        log_error "API tests failed"
        all_passed=false
    fi
    echo ""
    
    # Final result
    if [ "$all_passed" = true ]; then
        log_success "✅ All tests passed!"
        echo ""
        echo "🎉 System is healthy and ready for development!"
        echo ""
        echo "📊 Quick status:"
        echo "  Frontend:          http://localhost:3000"
        echo "  Text Service:      http://localhost:8000/health"
        echo "  Dictionary Service: http://localhost:8002/health"
        echo "  Learning Service:  http://localhost:8003/health"
        exit 0
    else
        log_error "❌ Some tests failed!"
        echo ""
        echo "💡 Try the following:"
        echo "  make logs          # Check service logs"
        echo "  make health        # Detailed health check"
        echo "  make restart       # Restart services"
        exit 1
    fi
}

main "$@"
