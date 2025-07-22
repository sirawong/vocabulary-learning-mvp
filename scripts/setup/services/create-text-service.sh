# scripts/setup/services/create-text-service.sh - Text Service Creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
source "$SCRIPT_DIR/../../utils/logger.sh"
source "$SCRIPT_DIR/../../utils/file-helpers.sh"

main() {
    local service_dir="$PROJECT_ROOT/services/text-service"
    
    log_debug "Creating Text Service in $service_dir..."
    
    # Create package.json
    cat > "$service_dir/package.json" << 'EOF'
{
  "name": "text-service",
  "version": "1.0.0",
  "description": "Text processing service for vocabulary learning",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext .ts",
    "test": "echo 'Tests not implemented yet'"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "redis": "^4.6.0",
    "cors": "^2.8.5",
    "helmet": "^6.1.0",
    "dotenv": "^16.0.3",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/node": "^18.15.0",
    "typescript": "^5.0.0",
    "ts-node-dev": "^2.0.0",
    "eslint": "^8.38.0",
    "@typescript-eslint/eslint-plugin": "^5.57.0",
    "@typescript-eslint/parser": "^5.57.0",
    "prettier": "^2.8.7"
  }
}
EOF

    # Create TypeScript config
    "$SCRIPT_DIR/../templates/create-service-tsconfig.sh" "$service_dir"
    
    # Create Dockerfiles
    "$SCRIPT_DIR/../templates/create-service-dockerfile.sh" "$service_dir" "8000"
    
    # Create main application
    cat > "$service_dir/src/index.ts" << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { createClient } from 'redis';
import { healthRoutes } from './controllers/health';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health routes
app.use('/', healthRoutes);

// Database connections
let redisClient: any;

const connectDatabases = async () => {
  try {
    // MongoDB connection
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/vocabulary_db';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Redis connection
    const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
    redisClient = createClient({ url: redisUrl });
    await redisClient.connect();
    console.log('✅ Connected to Redis');

  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
};

const startServer = async () => {
  try {
    await connectDatabases();
    
    app.listen(PORT, () => {
      console.log(`🚀 Text Service running on port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Shutting down gracefully...');
  if (redisClient) await redisClient.quit();
  await mongoose.connection.close();
  process.exit(0);
});

export { app, redisClient };
EOF

    # Create health controller
    "$SCRIPT_DIR/../templates/create-health-controller.sh" "$service_dir" "text-service"
    
    log_debug "Text Service created successfully"
}

main "$@"

# ---
