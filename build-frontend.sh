#!/bin/bash
set -e

echo "Building frontend applications..."

# Build CRM frontend
echo "Building CRM frontend..."
docker run --rm -v $(pwd)/CRM项目/web/crm:/app -w /app node:14-alpine sh -c "npm install && npm run build"

# Build CP frontend
echo "Building CP frontend..."
docker run --rm -v $(pwd)/CRM项目/web/cp-web:/app -w /app node:14-alpine sh -c "npm install && npm run build"

echo "Starting frontend services..."
docker-compose up -d crm-frontend cp-frontend
