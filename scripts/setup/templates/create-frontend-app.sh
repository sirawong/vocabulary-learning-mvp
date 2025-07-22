# scripts/setup/templates/create-frontend-app.sh - Frontend Application Files
#!/bin/bash

set -e

frontend_dir=$1

# Create app directory structure
mkdir -p "$frontend_dir/src/app"

# Global CSS
cat > "$frontend_dir/src/app/globals.css" << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-start-rgb: 214, 219, 220;
  --background-end-rgb: 255, 255, 255;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground-rgb: 255, 255, 255;
    --background-start-rgb: 0, 0, 0;
    --background-end-rgb: 0, 0, 0;
  }
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
}
EOF

# Layout component
cat > "$frontend_dir/src/app/layout.tsx" << 'EOF'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Vocabulary Learning MVP',
  description: 'Learn vocabulary from web content',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF

# Main page component
cat > "$frontend_dir/src/app/page.tsx" << 'EOF'
'use client';

import { useEffect, useState } from 'react';

interface ServiceHealth {
  status: string;
  service: string;
  timestamp: string;
  version?: string;
  dependencies?: {
    [key: string]: string;
  };
}

export default function Home() {
  const [services, setServices] = useState<{[key: string]: ServiceHealth}>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkServices = async () => {
      const serviceUrls = {
        'Text Service': 'http://localhost:8000/health',
        'Dictionary Service': 'http://localhost:8002/health',
        'Learning Service': 'http://localhost:8003/health'
      };

      const results: {[key: string]: ServiceHealth} = {};

      for (const [name, url] of Object.entries(serviceUrls)) {
        try {
          const response = await fetch(url);
          const data = await response.json();
          results[name] = data;
        } catch (error) {
          results[name] = {
            status: 'unhealthy',
            service: name.toLowerCase().replace(' ', '-'),
            timestamp: new Date().toISOString()
          };
        }
      }

      setServices(results);
      setLoading(false);
    };

    checkServices();
    const interval = setInterval(checkServices, 10000);
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status: string) => {
    return status === 'healthy' 
      ? 'bg-green-100 text-green-800' 
      : 'bg-red-100 text-red-800';
  };

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold mb-4 text-gray-800">
            Vocabulary Learning MVP
          </h1>
          <p className="text-xl text-gray-600">
            TypeScript Microservices Architecture
          </p>
        </div>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Service Health Section */}
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold mb-6 text-gray-700 flex items-center">
              <span className="mr-2">🏥</span>
              Service Health
            </h2>
            
            {loading ? (
              <div className="text-center py-8">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
                <p className="mt-4 text-gray-600">Checking services...</p>
              </div>
            ) : (
              <div className="space-y-4">
                {Object.entries(services).map(([name, health]) => (
                  <div key={name} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div className="flex justify-between items-start mb-3">
                      <h3 className="font-semibold text-lg">{name}</h3>
                      <div className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(health.status)}`}>
                        {health.status === 'healthy' ? '✅' : '❌'} {health.status}
                      </div>
                    </div>
                    
                    {health.dependencies && (
                      <div className="text-sm text-gray-600 mb-2">
                        <strong>Dependencies:</strong>
                        <div className="flex gap-4 mt-1">
                          {Object.entries(health.dependencies).map(([dep, status]) => (
                            <span key={dep} className="flex items-center">
                              {status === 'connected' ? '🟢' : '🔴'} {dep}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                    
                    <div className="flex justify-between text-sm text-gray-500">
                      <span>Version: {health.version || '1.0.0'}</span>
                      <span>Last checked: {new Date(health.timestamp).toLocaleTimeString()}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Architecture Overview */}
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold mb-6 text-gray-700 flex items-center">
              <span className="mr-2">🏗️</span>
              Architecture
            </h2>
            
            <div className="space-y-4">
              <div className="bg-blue-50 rounded-lg p-4">
                <h3 className="font-medium text-lg mb-2">Frontend (Port 3000)</h3>
                <p className="text-sm text-gray-600">Next.js 14 with TypeScript and TailwindCSS</p>
              </div>
              
              <div className="bg-green-50 rounded-lg p-4">
                <h3 className="font-medium text-lg mb-2">Text Service (Port 8000)</h3>
                <p className="text-sm text-gray-600">API Gateway - Express.js with TypeScript</p>
              </div>
              
              <div className="bg-yellow-50 rounded-lg p-4">
                <h3 className="font-medium text-lg mb-2">Dictionary Service (Port 8002)</h3>
                <p className="text-sm text-gray-600">Dictionary API integration</p>
              </div>
              
              <div className="bg-purple-50 rounded-lg p-4">
                <h3 className="font-medium text-lg mb-2">Learning Service (Port 8003)</h3>
                <p className="text-sm text-gray-600">Learning sessions management</p>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="font-medium text-lg mb-2">Databases</h3>
                <p className="text-sm text-gray-600">MongoDB (27017) & Redis (6379)</p>
              </div>
            </div>
          </div>
        </div>

        {/* Getting Started Section */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-2xl font-semibold mb-6 text-gray-700 flex items-center">
            <span className="mr-2">🚀</span>
            Development Status
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="font-medium text-lg mb-3 text-green-600">✅ Phase 1: Complete</h3>
              <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
                <li>TypeScript microservices architecture</li>
                <li>Docker containerization</li>
                <li>Database connections</li>
                <li>Health monitoring</li>
                <li>Development automation</li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-medium text-lg mb-3 text-blue-600">🔄 Phase 2: Planned</h3>
              <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
                <li>Text extraction from URLs</li>
                <li>Dictionary API integration</li>
                <li>Word processing</li>
                <li>Learning sessions</li>
                <li>User interface</li>
              </ul>
            </div>
          </div>
          
          <div className="mt-6 p-4 bg-blue-50 rounded-lg">
            <h4 className="font-medium mb-2">Make Commands</h4>
            <div className="text-sm text-gray-600 space-y-1">
              <code className="bg-gray-100 px-2 py-1 rounded">make health</code> - Check all services<br/>
              <code className="bg-gray-100 px-2 py-1 rounded">make logs</code> - View service logs<br/>
              <code className="bg-gray-100 px-2 py-1 rounded">make test</code> - Run tests<br/>
              <code className="bg-gray-100 px-2 py-1 rounded">make type-check</code> - TypeScript validation
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
EOF
