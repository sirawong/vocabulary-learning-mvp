# scripts/setup/services/create-dictionary-service.sh - Dictionary Service Creation
#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
source "$SCRIPT_DIR/../../utils/logger.sh"

main() {
    local service_dir="$PROJECT_ROOT/services/dictionary-service"
    
    log_debug "Creating Dictionary Service in $service_dir..."
    
    # Create package.json (based on text-service)
    sed 's/text-service/dictionary-service/g; s/Text processing/Dictionary/g' \
        "$PROJECT_ROOT/services/text-service/package.json" > "$service_dir/package.json"
    
    # Create TypeScript config
    "$SCRIPT_DIR/../templates/create-service-tsconfig.sh" "$service_dir"
    
    # Create Dockerfiles
    "$SCRIPT_DIR/../templates/create-service-dockerfile.sh" "$service_dir" "8002"
    
    # Create main application (based on text-service)
    sed 's/8000/8002/g; s/text-service/dictionary-service/g; s/Text Service/Dictionary Service/g' \
        "$PROJECT_ROOT/services/text-service/src/index.ts" > "$service_dir/src/index.ts"
    
    # Create health controller
    "$SCRIPT_DIR/../templates/create-health-controller.sh" "$service_dir" "dictionary-service"
    
    log_debug "Dictionary Service created successfully"
}

main "$@"

# ---
