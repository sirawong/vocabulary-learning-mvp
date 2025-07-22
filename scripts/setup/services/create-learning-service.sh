# scripts/setup/services/create-learning-service.sh - Learning Service Creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
source "$SCRIPT_DIR/../../utils/logger.sh"

main() {
    local service_dir="$PROJECT_ROOT/services/learning-service"
    
    log_debug "Creating Learning Service in $service_dir..."
    
    # Create package.json (based on dictionary-service)
    sed 's/dictionary-service/learning-service/g; s/Dictionary/Learning/g' \
        "$PROJECT_ROOT/services/dictionary-service/package.json" > "$service_dir/package.json"
    
    # Create TypeScript config
    "$SCRIPT_DIR/../templates/create-service-tsconfig.sh" "$service_dir"
    
    # Create Dockerfiles
    "$SCRIPT_DIR/../templates/create-service-dockerfile.sh" "$service_dir" "8003"
    
    # Create main application (based on dictionary-service)
    sed 's/8002/8003/g; s/dictionary-service/learning-service/g; s/Dictionary Service/Learning Service/g' \
        "$PROJECT_ROOT/services/dictionary-service/src/index.ts" > "$service_dir/src/index.ts"
    
    # Create health controller
    "$SCRIPT_DIR/../templates/create-health-controller.sh" "$service_dir" "learning-service"
    
    log_debug "Learning Service created successfully"
}

main "$@"

# ---
