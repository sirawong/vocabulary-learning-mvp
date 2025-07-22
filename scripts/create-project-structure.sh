# scripts/create-project-structure.sh - Create the complete directory structure
#!/bin/bash

set -e

PROJECT_ROOT="$(pwd)"

echo "📁 Creating complete project structure..."

# Main directories
mkdir -p frontend/src/{app,components,lib,types}
mkdir -p frontend/public

mkdir -p services/text-service/src/{controllers,services,models,utils,middleware}
mkdir -p services/text-service/tests

mkdir -p services/dictionary-service/src/{controllers,services,models,utils,middleware}
mkdir -p services/dictionary-service/tests

mkdir -p services/learning-service/src/{controllers,services,models,utils,middleware}
mkdir -p services/learning-service/tests

mkdir -p shared/{types,utils}

mkdir -p scripts/{setup/{services,templates,database},utils}

mkdir -p logs
mkdir -p data
mkdir -p tmp

echo "✅ Project structure created successfully!"

# ---
