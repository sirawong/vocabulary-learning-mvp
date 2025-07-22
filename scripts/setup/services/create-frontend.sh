# scripts/setup/services/create-frontend.sh - Frontend Creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
source "$SCRIPT_DIR/../../utils/logger.sh"

main() {
    local frontend_dir="$PROJECT_ROOT/frontend"
    
    log_debug "Creating Frontend in $frontend_dir..."
    
    # Create package.json
    cat > "$frontend_dir/package.json" << 'EOF'
{
  "name": "vocabulary-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "next build",
    "dev": "next dev",
    "lint": "next lint",
    "start": "next start",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18",
    "react-dom": "^18",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "autoprefixer": "^10.0.1",
    "eslint": "^8",
    "eslint-config-next": "14.0.0",
    "postcss": "^8",
    "tailwindcss": "^3.3.0"
  }
}
EOF

    # Create Next.js configuration files
    "$SCRIPT_DIR/../templates/create-nextjs-config.sh" "$frontend_dir"
    
    # Create frontend application files
    "$SCRIPT_DIR/../templates/create-frontend-app.sh" "$frontend_dir"
    
    log_debug "Frontend created successfully"
}

main "$@"
