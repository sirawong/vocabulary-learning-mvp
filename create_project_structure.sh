#!/bin/bash

# --- สร้างไดเรกทอรีหลัก ---
echo "กำลังสร้างไดเรกทอรี..."
mkdir -p scripts/utils
mkdir -p scripts/setup/services
mkdir -p scripts/setup/templates
mkdir -p scripts/setup/database

# --- สร้างไฟล์เปล่าทั้งหมด ---
echo "กำลังสร้างไฟล์สคริปต์..."

# /scripts
touch scripts/setup.sh
touch scripts/health-check.sh
touch scripts/test.sh
touch scripts/clean.sh
touch scripts/env-check.sh
touch scripts/update-progress.sh

# /scripts/utils
touch scripts/utils/logger.sh
touch scripts/utils/checks.sh
touch scripts/utils/file-helpers.sh

# /scripts/setup
touch scripts/setup/check-prerequisites.sh
touch scripts/setup/create-structure.sh
touch scripts/setup/setup-environment.sh
touch scripts/setup/init-services.sh
touch scripts/setup/install-dependencies.sh
touch scripts/setup/setup-dev-tools.sh
touch scripts/setup/create-docs.sh
touch scripts/setup/finalize-setup.sh

# /scripts/setup/services
touch scripts/setup/services/create-text-service.sh
touch scripts/setup/services/create-dictionary-service.sh
touch scripts/setup/services/create-learning-service.sh
touch scripts/setup/services/create-frontend.sh

# /scripts/setup/templates
touch scripts/setup/templates/create-service-tsconfig.sh
touch scripts/setup/templates/create-service-dockerfile.sh
touch scripts/setup/templates/create-health-controller.sh
touch scripts/setup/templates/create-nextjs-config.sh
touch scripts/setup/templates/create-frontend-app.sh

# /scripts/setup/database
touch scripts/setup/database/create-mongo-init.sh

echo "--- โครงสร้างโปรเจกต์ถูกสร้างเรียบร้อยแล้ว ---"

# แสดงโครงสร้างที่สร้างขึ้น
tree scripts

