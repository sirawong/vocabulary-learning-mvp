# Vocabulary Learning MVP

A TypeScript microservices-based vocabulary learning system that extracts text from URLs, processes vocabulary words, integrates with dictionary APIs, and creates interactive learning sessions.

## 🚀 Quick Start

```bash
git clone <repository>
cd vocabulary-learning-mvp
make setup      # Initialize everything
make dev        # Start development
make health     # Verify everything works
```

## 🏗️ Architecture

```
Frontend (3000) ──┐
                  ├──► Text Service (8000) ──┐
                  │                          ├──► MongoDB (27017)
                  ├──► Dictionary Service (8002) ──┤
                  │                          ├──► Redis (6379)
                  └──► Learning Service (8003) ──┘
```

## 📁 Project Structure

```
vocabulary-learning-mvp/
├── frontend/                    # Next.js 14 TypeScript app
├── services/
│   ├── text-service/           # API Gateway (Port 8000)
│   ├── dictionary-service/     # Dictionary API integration (Port 8002)
│   └── learning-service/       # Learning sessions (Port 8003)
├── shared/                     # Shared TypeScript types
├── scripts/                    # Automation scripts
├── docker-compose.yml          # Production configuration
├── docker-compose.dev.yml      # Development configuration
├── Makefile                   # Main automation commands
└── README.md
```

## 🛠️ Technology Stack

- **Frontend**: Next.js 14, TypeScript, TailwindCSS
- **Backend**: Node.js, Express, TypeScript
- **Databases**: MongoDB, Redis
- **DevOps**: Docker, Docker Compose
- **Development**: Hot reload, ESLint, Prettier

## 📋 Make Commands

### Core Commands
```bash
make setup      # Initialize entire project (run once)
make dev        # Start all services in development mode
make health     # Check health of all services
make test       # Run tests and validations
```

### Development Commands
```bash
make type-check # Run TypeScript type checking
make logs       # Show logs from all services
make status     # Show container status and resource usage
make restart    # Stop and restart all services
```

### Management Commands
```bash
make stop       # Stop all services
make clean      # Remove containers and images
make install    # Install dependencies for all services
```

### Service Access
```bash
make shell-text      # Open shell in text service container
make shell-dict      # Open shell in dictionary service container
make shell-learning  # Open shell in learning service container
make shell-frontend  # Open shell in frontend container
```

## 🌐 Service Endpoints

| Service | Port | Health Check | Description |
|---------|------|--------------|-------------|
| Frontend | 3000 | `http://localhost:3000` | Next.js web interface |
| Text Service | 8000 | `http://localhost:8000/health` | API Gateway |
| Dictionary Service | 8002 | `http://localhost:8002/health` | Dictionary integration |
| Learning Service | 8003 | `http://localhost:8003/health` | Learning sessions |
| MongoDB | 27017 | - | Database |
| Redis | 6379 | - | Cache |

## 🏥 Health Monitoring

Each service provides detailed health information:

```typescript
interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  service: string;
  version: string;
  dependencies: {
    mongodb: 'connected' | 'disconnected';
    redis: 'connected' | 'disconnected';
  };
}
```

## 🔧 Development Workflow

1. **Start Development**
   ```bash
   make dev
   ```

2. **Make Changes**
   - Edit source code in `services/*/src/` or `frontend/src/`
   - Services auto-reload with hot reload

3. **Check Health**
   ```bash
   make health
   ```

4. **View Logs**
   ```bash
   make logs
   # or for specific service
   make logs-service SERVICE=text-service
   ```

5. **Run Tests**
   ```bash
   make test
   ```

## 📝 Environment Configuration

Copy `.env.example` to `.env` and configure:

```bash
# Database Configuration
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=password123
MONGO_DATABASE=vocabulary_db

# Redis Configuration
REDIS_URL=redis://localhost:6379

# API Keys
DICTIONARY_API_KEY=your_dictionary_api_key_here

# Service URLs
TEXT_SERVICE_URL=http://localhost:8000
DICTIONARY_SERVICE_URL=http://localhost:8002
LEARNING_SERVICE_URL=http://localhost:8003
```

## 🐳 Docker Configuration

### Development
- Hot reload enabled
- Source code mounted as volumes
- Development dependencies included
- Detailed logging

### Production
- Multi-stage builds for optimization
- Non-root user for security
- Health checks configured
- Minimal attack surface

## 📊 Current Status - Phase 1 ✅

### ✅ Completed Features
- [x] Complete TypeScript microservices architecture
- [x] Docker containerization with multi-stage builds
- [x] Development environment with hot reload
- [x] Health monitoring for all services
- [x] Database connections (MongoDB, Redis)
- [x] Next.js frontend with service status dashboard
- [x] Make automation for all workflows
- [x] Comprehensive documentation
- [x] Progress tracking system

### 🔄 Current Capabilities
- All services running and healthy
- TypeScript compilation and type checking
- Database connectivity
- Service-to-service communication ready
- Development workflow fully automated
- Health monitoring and logging

## 🚧 Next Phases

### Phase 2: Core Functionality (Planned)
- [ ] Text extraction from URLs
- [ ] Dictionary API integration
- [ ] Word processing and analysis
- [ ] Basic vocabulary storage

### Phase 3: Learning Features (Planned)
- [ ] Interactive learning sessions
- [ ] Progress tracking
- [ ] Spaced repetition algorithm
- [ ] User interface enhancements

### Phase 4: Advanced Features (Planned)
- [ ] User authentication
- [ ] Personal vocabulary lists
- [ ] Learning analytics
- [ ] Mobile responsiveness

## 🐛 Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using the ports
   lsof -i :3000,8000,8002,8003,27017,6379
   # Kill conflicting processes or change ports in .env
   ```

2. **Docker Issues**
   ```bash
   make clean      # Clean everything
   make dev        # Restart
   ```

3. **Database Connection Issues**
   ```bash
   make logs-service SERVICE=text-service
   # Check MongoDB and Redis container logs
   ```

4. **Health Check Failures**
   ```bash
   make health     # Detailed health check
   make status     # Container resource usage
   ```

### Getting Help
- Check service logs: `make logs`
- Verify environment: `make env-check`
- Clean restart: `make clean && make dev`
- Check progress: see `PROGRESS.md`

## 📚 Documentation

- [`SETUP.md`](SETUP.md) - Detailed setup instructions
- [`PROGRESS.md`](PROGRESS.md) - Development progress tracking
- `services/*/STATUS.md` - Individual service status

## 🤝 Contributing

1. Make changes to source code
2. Test with `make test`
3. Check types with `make type-check`
4. Update progress with `make update-progress`

## 📄 License

MIT License - see LICENSE file for details.

---

**Ready for Phase 2 Implementation!** 🎉

The infrastructure is complete and ready for core functionality development. All services are properly containerized, typed, and monitored.
