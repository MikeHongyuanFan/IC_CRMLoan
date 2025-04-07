#!/bin/bash
set -e

echo "Building frontend applications..."

# Remove any existing frontend builder containers
echo "Cleaning up any existing frontend builder containers..."
docker rm -f crm-frontend-builder cp-frontend-builder 2>/dev/null || true

# Build CRM frontend using a Node.js image with Python installed
echo "Building CRM frontend..."
docker run --name crm-frontend-builder \
  -v $(pwd)/CRM项目/web/crm:/app \
  -w /app \
  node:14-alpine \
  sh -c "apk add --no-cache python3 make g++ && npm install && npm run build" || {
    echo "CRM frontend build failed. Check the logs above for errors."
    docker rm -f crm-frontend-builder 2>/dev/null || true
    exit 1
  }

# Create target directory for frontend builds
mkdir -p frontend-dist/crm
mkdir -p frontend-dist/cp-web

# Copy the built files from the container to the host
echo "Copying CRM frontend build files..."
docker cp crm-frontend-builder:/app/dist/. frontend-dist/crm/ || {
  echo "Failed to copy CRM frontend build files. The build may have failed."
  docker rm -f crm-frontend-builder 2>/dev/null || true
  exit 1
}

# Clean up the container
echo "Cleaning up CRM frontend container..."
docker rm crm-frontend-builder

# Build CP frontend using a Node.js image with Python installed
echo "Building CP frontend..."
docker run --name cp-frontend-builder \
  -v $(pwd)/CRM项目/web/cp-web:/app \
  -w /app \
  node:14-alpine \
  sh -c "apk add --no-cache python3 make g++ && npm install && npm run build" || {
    echo "CP frontend build failed. Check the logs above for errors."
    docker rm -f cp-frontend-builder 2>/dev/null || true
    exit 1
  }

# Copy the built files from the container to the host
echo "Copying CP frontend build files..."
docker cp cp-frontend-builder:/app/dist/. frontend-dist/cp-web/ || {
  echo "Failed to copy CP frontend build files. The build may have failed."
  docker rm -f cp-frontend-builder 2>/dev/null || true
  exit 1
}

# Clean up the container
echo "Cleaning up CP frontend container..."
docker rm cp-frontend-builder

echo "Frontend build completed successfully!"
