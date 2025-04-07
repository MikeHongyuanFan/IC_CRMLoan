#!/bin/bash

echo "Cleaning up all containers and volumes..."

# Stop and remove all containers from docker-compose
docker-compose down -v

# Remove any builder containers that might be left over
docker rm -f maven-builder crm-frontend-builder cp-frontend-builder 2>/dev/null || true

# Remove any orphaned containers with the gls prefix
docker ps -a | grep 'gls-' | awk '{print $1}' | xargs docker rm -f 2>/dev/null || true

echo "Cleanup completed successfully!"
echo "You can now run './deploy-local.sh' to start a fresh deployment."
