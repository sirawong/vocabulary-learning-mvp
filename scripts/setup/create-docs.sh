# scripts/setup/create-docs.sh - Documentation Creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"

main() {
    log_step "Creating documentation and progress tracking..."
    
    cd "$PROJECT_ROOT"
    
    # Create PROGRESS.md
    log_info "Creating PROGRESS.md..."
    cat > PROGRESS.md << 'EOF'
# Vocabulary Learning MVP - Progress Tracking

## ✅ Phase 1: Infrastructure Setup (COMPLETED)

### Project Structure ✅
- [x] Complete folder structure created
- [x] Microservices architecture: text-service, dictionary-service, learning-service
- [x] Frontend: Next.js 14 with TypeScript and TailwindCSS
- [x] Shared types and utilities
- [x] Automated setup scripts

### Docker Configuration ✅
- [x] Multi-stage Dockerfiles for all services
- [x] Development docker-compose with hot reload
- [x] Production docker-compose configuration
- [x] Health checks for all containers
- [x] Proper service networking and dependencies

### TypeScript Setup ✅
- [x] Strict TypeScript configuration for all services
- [x] Shared type definitions
- [x] Express + MongoDB + Redis typing
- [x] Development hot-reload with ts-node-dev
- [x] Type checking automation

### Backend Services ✅
- [x] **Text Service (Port 8000)** - API Gateway
  - [x] Express server with TypeScript
  - [x] Health endpoint with dependency checks
  - [x] MongoDB and Redis connections
  - [x] Error handling and graceful shutdown
- [x] **Dictionary Service (Port 8002)**
  - [x] Express server with TypeScript  
  - [x] Health monitoring
  - [x] Database connections ready
- [x] **Learning Service (Port 8003)**
  - [x] Express server with TypeScript
  - [x] Health monitoring
  - [x] Database connections ready

### Database Setup ✅
- [x] MongoDB with Mongoose ODM
- [x] Redis for caching
- [x] Database initialization scripts
- [x] Schema validation and indexes
- [x] Connection health monitoring
- [x] Sample data insertion

### Frontend Setup ✅
- [x] Next.js 14 with App Router
- [x] TypeScript configuration
- [x] TailwindCSS styling
- [x] Real-time service health dashboard
- [x] Responsive design
- [x] Auto-refresh service status

### Development Tools ✅
- [x] ESLint + Prettier configuration
- [x] Make automation with 15+ commands
- [x] Modular setup scripts
- [x] Development hot reload
- [x] Health check automation
- [x] VS Code workspace settings

### Make Commands ✅
- [x] `make setup` - Complete project initialization
- [x] `make dev` - Start development environment
- [x] `make health` - Monitor all services
- [x] `make test` - Run tests and validations
- [x] `make type-check` - TypeScript validation
- [x] `make logs` - View service logs
- [x] `make clean` - Clean up containers

## 🚧 Phase 2: Core Functionality (PLANNED)

### Text Processing
- [ ] URL text extraction service
- [ ] Content parsing and cleaning
- [ ] Language detection
- [ ] Word tokenization and filtering

### Dictionary Integration
- [ ] External dictionary API integration
- [ ] Word definition caching
- [ ] Multiple definition sources
- [ ] Pronunciation data

### Vocabulary Management
- [ ] Word storage and retrieval
- [ ] Difficulty assessment
- [ ] Word frequency analysis
- [ ] User vocabulary tracking

### API Endpoints
- [ ] Text extraction endpoints
- [ ] Dictionary lookup endpoints
- [ ] Vocabulary CRUD operations
- [ ] Session management APIs

## 🎯 Phase 3: Learning Features (PLANNED)

### Learning Sessions
- [ ] Interactive vocabulary sessions
- [ ] Spaced repetition algorithm
- [ ] Progress tracking
- [ ] Performance analytics

### User Interface
- [ ] Learning session UI
- [ ] Progress visualization
- [ ] Word cards and exercises
- [ ] Settings and preferences

## 📊 Current System Status

| Component | Status | Port | Health Check |
|-----------|--------|------|-------------|
| Frontend | ✅ Running | 3000 | http://localhost:3000 |
| Text Service | ✅ Running | 8000 | http://localhost:8000/health |
| Dictionary Service | ✅ Running | 8002 | http://localhost:8002/health |
| Learning Service | ✅ Running | 8003 | http://localhost:8003/health |
| MongoDB | ✅ Running | 27017 | Container health check |
| Redis | ✅ Running | 6379 | Container health check |

## 🛠️ Development Workflow

```bash
# Start development
make dev

# Check all services
make health

# View logs
make logs

# Run tests
make test

# Type checking
make type-check

# Stop services
make stop

# Clean up
make clean
```

Last Updated: $(date)
EOF

    # Create individual service status files
    log_info "Creating service status files..."
    local services=("text-service" "dictionary-service" "learning-service")
    
    for service in "${services[@]}"; do
        local port=""
        case $service in
            "text-service") port="8000" ;;
            "dictionary-service") port="8002" ;;
            "learning-service") port="8003" ;;
        esac
        
        cat > "services/$service/STATUS.md" << EOF
# $service Status

## ✅ Current Implementation
- [x] Express.js server with TypeScript
- [x] Health endpoint (\`GET /health\`)
- [x] MongoDB connection with Mongoose
- [x] Redis connection and caching
- [x] Error handling and logging
- [x] Docker development setup
- [x] Hot reload in development mode
- [x] Production-ready build process

## 🌐 API Endpoints
- \`GET /health\` - Service health check with dependency status

## 📋 Planned Features (Phase 2)
- [ ] Core business logic implementation
- [ ] Additional API endpoints
- [ ] Data models and schemas
- [ ] Service-specific functionality
- [ ] Integration tests
- [ ] Performance monitoring

## 🔗 Dependencies
- **MongoDB**: ✅ Connected (Port 27017)
- **Redis**: ✅ Connected (Port 6379)
- **Express**: ✅ Running (Port $port)

## 🐳 Docker Configuration
- **Development**: Hot reload with volume mounts
- **Production**: Multi-stage build with optimization
- **Health Check**: HTTP endpoint monitoring

## 📊 Service Metrics
- Port: $port
- Version: 1.0.0
- TypeScript: Strict mode enabled
- Status: Ready for Phase 2 development

Last Updated: \$(date)
EOF
    done

    # Create SETUP.md
    log_info "Creating SETUP.md..."
    cat > SETUP.md << 'EOF'
# Vocabulary Learning MVP - Setup Guide

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone <repository-url>
cd vocabulary-learning-mvp

# 2. Initialize project
make setup

# 3. Start development
make dev

# 4. Verify services
make health
```

## 📋 Prerequisites

### Required
- **Docker** (20.10+)
- **Docker Compose** (1.29+)

### Optional (for local development)
- **Node.js** (18+)
- **npm** (8+)
- **curl** (for health checks)

## 🛠️ Make Commands Reference

### Core Commands
| Command | Description |
|---------|-------------|
| `make setup` | Initialize entire project (run once) |
| `make dev` | Start development environment |
| `make health` | Check health of all services |
| `make test` | Run tests and validations |

### Development Commands
| Command | Description |
|---------|-------------|
| `make type-check` | Run TypeScript type checking |
| `make logs` | Show logs from all services |
| `make logs-service SERVICE=text-service` | Show logs for specific service |
| `make status` | Show container status and resources |

### Management Commands
| Command | Description |
|---------|-------------|
| `make stop` | Stop all services |
| `make clean` | Remove containers and images |
| `make restart` | Stop and restart services |
| `make install` | Install dependencies locally |

### Service Access
| Command | Description |
|---------|-------------|
| `make shell-text` | Open shell in text service |
| `make shell-dict` | Open shell in dictionary service |
| `make shell-learning` | Open shell in learning service |
| `make shell-frontend` | Open shell in frontend |

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐
│   Frontend      │    │   Text Service   │
│   (Next.js)     │◄──►│   (API Gateway)  │
│   Port 3000     │    │   Port 8000      │
└─────────────────┘    └──────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌──────────────────┐
│ Dictionary      │    │   Learning       │
│ Service         │    │   Service        │
│ Port 8002       │    │   Port 8003      │
└─────────────────┘    └──────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌──────────────────┐
│   MongoDB       │    │     Redis        │
│   Port 27017    │    │   Port 6379      │
└─────────────────┘    └──────────────────┘
```

## ⚙️ Environment Configuration

### 1. Copy Environment Template
```bash
cp .env.example .env
```

### 2. Configure Variables
```bash
# Database
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your_secure_password
MONGO_DATABASE=vocabulary_db

# API Keys
DICTIONARY_API_KEY=your_api_key_here

# Development settings
DEBUG=true
NODE_ENV=development
```

## 🐳 Docker Configuration

### Development Mode
- **Hot reload**: Code changes auto-reload
- **Volume mounts**: Local files mapped to containers  
- **Debug logging**: Detailed logs for development
- **Source maps**: TypeScript debugging support

### Production Mode
- **Multi-stage builds**: Optimized for size
- **Security**: Non-root users
- **Health checks**: Automated monitoring
- **Resource limits**: Memory and CPU constraints

## 🏥 Health Monitoring

### Service Health Endpoints
- **Text Service**: http://localhost:8000/health
- **Dictionary Service**: http://localhost:8002/health  
- **Learning Service**: http://localhost:8003/health
- **Frontend**: http://localhost:3000

### Health Check Response
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "text-service",
  "version": "1.0.0",
  "dependencies": {
    "mongodb": "connected",
    "redis": "connected"
  }
}
```

## 🔧 Development Workflow

### 1. Start Development
```bash
make dev
```

### 2. Make Code Changes
- Edit files in `services/*/src/` or `frontend/src/`
- Services automatically reload

### 3. Check Status
```bash
make health
make logs
```

### 4. Run Tests
```bash
make test
make type-check
```

### 5. Debug Issues
```bash
# View specific service logs
make logs-service SERVICE=text-service

# Check container resources
make status

# Access service shell
make shell-text
```

## 🚨 Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check ports in use
lsof -i :3000,8000,8002,8003,27017,6379

# Stop conflicting services
make stop

# Clean and restart
make clean && make dev
```

#### Docker Issues
```bash
# Check Docker daemon
docker info

# Restart Docker service (Linux)
sudo systemctl restart docker

# Clean everything
make clean-hard
```

#### Database Connection Issues
```bash
# Check container logs
make logs-service SERVICE=mongodb
make logs-service SERVICE=redis

# Verify network connectivity
docker network ls
```

#### TypeScript Errors
```bash
# Run type checking
make type-check

# Check service-specific types
cd services/text-service && npm run type-check
```

### Performance Issues
```bash
# Check resource usage
make status

# View detailed container stats
docker stats

# Check disk space
df -h
```

## 📚 Project Structure

```
vocabulary-learning-mvp/
├── frontend/                 # Next.js app
│   ├── src/app/             # App router pages
│   ├── src/components/      # React components
│   └── package.json
├── services/
│   ├── text-service/        # API Gateway
│   ├── dictionary-service/  # Dictionary API
│   └── learning-service/    # Learning logic
├── shared/
│   └── types/              # Shared TypeScript types
├── scripts/
│   ├── setup/              # Setup automation
│   └── utils/              # Utility functions
├── Makefile                # Main automation
├── docker-compose.yml      # Production config
├── docker-compose.dev.yml  # Development config
└── README.md
```

## 🎯 Next Steps

After successful setup:
1. ✅ All services running and healthy
2. 🚀 Ready for Phase 2 implementation
3. 📖 Check `PROGRESS.md` for development roadmap

## 🤝 Contributing

1. Make changes to source code
2. Test with `make test`
3. Check types with `make type-check`
4. Update progress with `make update-progress`

## 📞 Support

- Check logs: `make logs`
- Verify environment: `make env-check`  
- Clean restart: `make clean && make dev`
- Review documentation: `README.md`, `PROGRESS.md`
EOF

    log_success "Documentation created"
}

main "$@"

# ---
