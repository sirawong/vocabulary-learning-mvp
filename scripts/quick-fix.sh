#!/bin/bash

# Quick Fix Script - แก้ไขปัญหา logger.sh และ modular setup
# รันไฟล์นี้เพื่อแก้ไขปัญหาทันที

set -e

echo "🔧 กำลังแก้ไขปัญหา scripts..."

# สร้าง scripts/utils directory และไฟล์ที่จำเป็น
mkdir -p scripts/utils
mkdir -p scripts/setup/services
mkdir -p scripts/setup/templates
mkdir -p scripts/setup/database

# สร้าง logger.sh
cat > scripts/utils/logger.sh << 'EOF'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
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

log_debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local description=$3
    
    if [ "$total" -eq 0 ]; then
        echo "$description"
        return
    fi
    
    local percentage=$((current * 100 / total))
    local filled=$((current * 30 / total))
    local empty=$((30 - filled))
    
    printf "\r${BLUE}[%3d%%]${NC} [" "$percentage"
    printf "%*s" "$filled" | tr ' ' '█'
    printf "%*s" "$empty" | tr ' ' '░'
    printf "] %s" "$description"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}
EOF

# สร้าง checks.sh
cat > scripts/utils/checks.sh << 'EOF'
#!/bin/bash

# Check if command exists
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

# Check if port is available
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
        log_debug "lsof not available, skipping port check for $port"
        return 0
    fi
}

# Check Docker daemon
check_docker_daemon() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log_success "Docker daemon is running"
        return 0
    else
        log_error "Docker daemon is not running"
        return 1
    fi
}

# Ensure directory exists
ensure_directory() {
    local dir=$1
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    else
        log_debug "Directory exists: $dir"
    fi
}
EOF

# แก้ไข update-progress.sh
cat > scripts/update-progress.sh << 'EOF'
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
EOF

# แก้ไข health-check.sh ให้ทำงานได้โดยไม่ต้องพึ่ง utils
cat > scripts/health-check.sh << 'EOF'
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
EOF

# แก้ไข env-check.sh
cat > scripts/env-check.sh << 'EOF'
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
EOF

# แก้ไข test.sh
cat > scripts/test.sh << 'EOF'
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
EOF

# แก้ไข clean.sh
cat > scripts/clean.sh << 'EOF'
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
EOF

# สร้าง setup.sh แบบง่ายที่ทำงานได้ทันที
cat > scripts/setup.sh << 'EOF'
#!/bin/bash

# Vocabulary Learning MVP - Main Setup Script
# แก้ไขให้ทำงานได้โดยไม่ต้องพึ่ง modular scripts

set -e  # Exit on error

# Colors
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

main() {
    log_info "🚀 Starting Vocabulary Learning MVP Setup..."
    echo ""
    
    # Check prerequisites
    log_info "📋 Checking prerequisites..."
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
    echo ""
    
    # Create environment file
    log_info "⚙️  Setting up environment..."
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            log_success "Created .env file from template"
        else
            log_warning ".env.example not found, you may need to create .env manually"
        fi
    else
        log_info ".env file already exists"
    fi
    echo ""
    
    # Check if all necessary files exist
    log_info "📁 Checking project structure..."
    required_files=(
        "Makefile"
        "docker-compose.dev.yml"
    )
    
    missing_files=false
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file missing: $file"
            missing_files=true
        fi
    done
    
    if [ "$missing_files" = true ]; then
        log_error "Some required files are missing. Please ensure you have the complete project."
        exit 1
    fi
    
    log_success "Project structure check passed"
    echo ""
    
    # Make scripts executable
    log_info "🔧 Making scripts executable..."
    find scripts -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    log_success "Scripts made executable"
    echo ""
    
    # Success message
    log_success "✅ Setup completed successfully!"
    echo ""
    log_info "🎉 Vocabulary Learning MVP is ready!"
    echo ""
    echo "Next steps:"
    echo "  make dev      # Start development environment"
    echo "  make health   # Check all services"
    echo "  make test     # Run tests"
    echo ""
    echo "📚 Documentation:"
    echo "  README.md     # Project overview"
    echo "  SETUP.md      # Detailed setup guide (if available)"
    echo "  PROGRESS.md   # Development progress (if available)"
}

main "$@"
EOF

# Make all scripts executable
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x scripts/utils/*.sh 2>/dev/null || true

echo "✅ แก้ไขปัญหาเสร็จสิ้น!"
echo ""
echo "🎯 ตอนนี้คุณสามารถใช้คำสั่งเหล่านี้ได้:"
echo "  make setup      # ติดตั้งโปรเจค"
echo "  make dev        # เริ่ม development"  
echo "  make health     # ตรวจสอบสถานะ"
echo "  make test       # รัน tests"
echo "  make update-progress  # อัพเดทความคืบหน้า"
echo ""
echo "📝 Scripts ที่แก้ไขแล้ว:"
echo "  ✅ scripts/utils/logger.sh"
echo "  ✅ scripts/utils/checks.sh" 
echo "  ✅ scripts/setup.sh"
echo "  ✅ scripts/update-progress.sh"
echo "  ✅ scripts/health-check.sh"
echo "  ✅ scripts/env-check.sh"
echo "  ✅ scripts/test.sh"
echo "  ✅ scripts/clean.sh"
