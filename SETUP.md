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
