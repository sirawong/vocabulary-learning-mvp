import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { createClient } from 'redis';
import { healthRoutes } from './controllers/health';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8002;

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
      console.log(`🚀 Dictionary Service running on port ${PORT}`);
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
