# scripts/setup/setup-dev-tools.sh - Development Tools Setup
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$SCRIPT_DIR/../utils/logger.sh"

main() {
    log_step "Setting up development tools..."
    
    cd "$PROJECT_ROOT"
    
    # Create ESLint config for services
    log_info "Creating ESLint configurations..."
    cat > services/text-service/.eslintrc.js << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  extends: [
    '@typescript-eslint/recommended',
  ],
  rules: {
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-inferrable-types': 'off',
  },
};
EOF
    
    # Copy ESLint config to other services
    cp services/text-service/.eslintrc.js services/dictionary-service/.eslintrc.js
    cp services/text-service/.eslintrc.js services/learning-service/.eslintrc.js
    
    # Create Prettier config
    log_info "Creating Prettier configuration..."
    cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
EOF

    # Create .prettierignore
    cat > .prettierignore << 'EOF'
node_modules/
dist/
build/
.next/
coverage/
*.log
EOF

    # Create shared types
    log_info "Creating shared TypeScript types..."
    mkdir -p shared/types
    
    cat > shared/types/health.ts << 'EOF'
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
EOF

    cat > shared/types/api.ts << 'EOF'
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: any;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
EOF

    cat > shared/types/index.ts << 'EOF'
export * from './health';
export * from './api';
EOF

    # Create VS Code workspace settings (optional)
    log_info "Creating VS Code workspace settings..."
    mkdir -p .vscode
    
    cat > .vscode/settings.json << 'EOF'
{
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.workingDirectories": [
    "frontend",
    "services/text-service",
    "services/dictionary-service",
    "services/learning-service"
  ],
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.next": true
  }
}
EOF

    cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-docker",
    "bradlc.vscode-tailwindcss"
  ]
}
EOF

    log_success "Development tools configured"
}

main "$@"

# ---
