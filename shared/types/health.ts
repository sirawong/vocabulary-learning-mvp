export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  service: string;
  version: string;
  dependencies?: {
    [key: string]: 'connected' | 'disconnected';
  };
}

export interface ServiceConfig {
  name: string;
  port: number;
  url: string;
  healthPath: string;
}

export interface DatabaseConfig {
  mongodb: {
    uri: string;
    database: string;
  };
  redis: {
    url: string;
  };
}
