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
