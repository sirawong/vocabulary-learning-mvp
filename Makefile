# Vocabulary Learning MVP - Makefile
# Main automation commands for development workflow

.PHONY: help setup env-check dev health test type-check stop clean logs status

# Default target
help: ## Show this help message
	@echo "Vocabulary Learning MVP - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup    # Initialize project"
	@echo "  make dev      # Start development"
	@echo "  make health   # Check all services"
	@echo "  make test     # Run tests"

setup: ## Initialize entire project and install dependencies
	@echo "🚀 Setting up Vocabulary Learning MVP..."
	@./scripts/setup.sh

env-check: ## Validate environment and dependencies
	@echo "🔍 Checking environment..."
	@./scripts/env-check.sh

dev: ## Start all services in development mode
	@echo "🏗️  Starting development environment..."
	@docker-compose -f docker-compose.dev.yml up --build

dev-detached: ## Start development services in background
	@echo "🏗️  Starting development environment (detached)..."
	@docker-compose -f docker-compose.dev.yml up -d --build

prod: ## Start production environment
	@echo "🚀 Starting production environment..."
	@docker-compose up -d --build

health: ## Check health of all services
	@echo "🏥 Checking service health..."
	@./scripts/health-check.sh

test: ## Run all tests and health checks
	@echo "🧪 Running tests..."
	@./scripts/test.sh

type-check: ## Run TypeScript type checking on all services
	@echo "🔍 Running TypeScript type check..."
	@echo "Checking Text Service..."
	@cd services/text-service && npm run type-check
	@echo "Checking Dictionary Service..."
	@cd services/dictionary-service && npm run type-check
	@echo "Checking Learning Service..."
	@cd services/learning-service && npm run type-check
	@echo "Checking Frontend..."
	@cd frontend && npm run type-check
	@echo "✅ All TypeScript checks passed!"

logs: ## Show logs from all services
	@docker-compose -f docker-compose.dev.yml logs -f

logs-service: ## Show logs for specific service (usage: make logs-service SERVICE=text-service)
	@docker-compose -f docker-compose.dev.yml logs -f $(SERVICE)

stop: ## Stop all running services
	@echo "🛑 Stopping all services..."
	@docker-compose -f docker-compose.dev.yml down
	@docker-compose down

clean: ## Clean up containers, images, and volumes
	@echo "🧹 Cleaning up..."
	@./scripts/clean.sh

clean-hard: ## Nuclear cleanup - remove everything including volumes
	@echo "💣 Nuclear cleanup..."
	@docker-compose -f docker-compose.dev.yml down -v --remove-orphans
	@docker-compose down -v --remove-orphans
	@docker system prune -af --volumes

status: ## Show status of all services and containers
	@echo "📊 Service Status:"
	@echo "=================="
	@docker-compose -f docker-compose.dev.yml ps
	@echo ""
	@echo "🐳 Docker Resources:"
	@echo "==================="
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

install: ## Install dependencies for all services
	@echo "📦 Installing dependencies..."
	@cd frontend && npm install
	@cd services/text-service && npm install
	@cd services/dictionary-service && npm install
	@cd services/learning-service && npm install
	@echo "✅ Dependencies installed!"

update-progress: ## Update progress tracking
	@echo "📝 Updating progress tracking..."
	@./scripts/update-progress.sh

shell-text: ## Open shell in text service container
	@docker-compose -f docker-compose.dev.yml exec text-service sh

shell-dict: ## Open shell in dictionary service container
	@docker-compose -f docker-compose.dev.yml exec dictionary-service sh

shell-learning: ## Open shell in learning service container
	@docker-compose -f docker-compose.dev.yml exec learning-service sh

shell-frontend: ## Open shell in frontend container
	@docker-compose -f docker-compose.dev.yml exec frontend sh

# Development shortcuts
quick-start: setup dev ## Quick start: setup + dev
restart: stop dev ## Restart all services
rebuild: stop dev ## Rebuild and restart services
