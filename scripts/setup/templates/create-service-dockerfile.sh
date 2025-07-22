# scripts/setup/templates/create-service-dockerfile.sh - Dockerfile Templates
#!/bin/bash

set -e

service_dir=$1
port=$2

# Development Dockerfile
cat > "$service_dir/Dockerfile.dev" << EOF
FROM node:18-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

EXPOSE $port

CMD ["npm", "run", "dev"]
EOF

# Production Dockerfile
cat > "$service_dir/Dockerfile" << EOF
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
COPY tsconfig.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source and build
COPY src/ ./src/
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \\
    adduser -S nodeuser -u 1001

USER nodeuser

EXPOSE $port

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
  CMD curl -f http://localhost:$port/health || exit 1

CMD ["node", "dist/index.js"]
EOF

# ---
