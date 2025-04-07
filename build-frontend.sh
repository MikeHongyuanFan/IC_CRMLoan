#!/bin/bash
set -e

echo "Building frontend applications..."

# Remove any existing frontend builder containers
echo "Cleaning up any existing frontend builder containers..."
docker rm -f crm-frontend-builder cp-frontend-builder 2>/dev/null || true

# Build CRM frontend
echo "Building CRM frontend..."
docker run --name crm-frontend-builder -v $(pwd)/CRM项目/web/crm:/app -w /app node:14-alpine sh -c "npm install && npm run build"

# Create target directory for frontend builds
mkdir -p frontend-dist/crm
mkdir -p frontend-dist/cp-web

# Copy the built files from the container to the host
echo "Copying CRM frontend build files..."
docker cp crm-frontend-builder:/app/dist/. frontend-dist/crm/

# Clean up the container
echo "Cleaning up CRM frontend container..."
docker rm crm-frontend-builder

# Build CP frontend
echo "Building CP frontend..."
docker run --name cp-frontend-builder -v $(pwd)/CRM项目/web/cp-web:/app -w /app node:14-alpine sh -c "npm install && npm run build"

# Copy the built files from the container to the host
echo "Copying CP frontend build files..."
docker cp cp-frontend-builder:/app/dist/. frontend-dist/cp-web/

# Clean up the container
echo "Cleaning up CP frontend container..."
docker rm cp-frontend-builder

echo "Frontend build completed successfully!"
