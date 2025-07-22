# scripts/setup/templates/create-health-controller.sh - Health Controller Template
#!/bin/bash

set -e

service_dir=$1
service_name=$2

mkdir -p "$service_dir/src/controllers"

cat > "$service_dir/src/controllers/health.ts" << EOF
import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { redisClient } from '../index';

export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  service: '$service_name';
  version: string;
  dependencies: {
    mongodb: 'connected' | 'disconnected';
    redis: 'connected' | 'disconnected';
  };
}

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
  try {
    const mongoStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
    const redisStatus = redisClient?.isOpen ? 'connected' : 'disconnected';
    
    const isHealthy = mongoStatus === 'connected' && redisStatus === 'connected';
    
    const health: HealthResponse = {
      status: isHealthy ? 'healthy' : 'unhealthy',
      timestamp: new Date().toISOString(),
      service: '$service_name',
      version: '1.0.0',
      dependencies: {
        mongodb: mongoStatus,
        redis: redisStatus
      }
    };

    const statusCode = isHealthy ? 200 : 503;
    res.status(statusCode).json(health);
    
  } catch (error) {
    const health: HealthResponse = {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      service: '$service_name',
      version: '1.0.0',
      dependencies: {
        mongodb: 'disconnected',
        redis: 'disconnected'
      }
    };
    
    res.status(503).json(health);
  }
});

export const healthRoutes = router;
EOF

# ---
