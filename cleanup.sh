#!/bin/bash

echo "Cleaning up CRM Loan System deployment..."

# Stop and remove all containers from docker-compose
echo "Stopping and removing docker-compose services..."
docker-compose down -v 2>/dev/null || true

# Remove any leftover containers
echo "Removing any leftover containers..."
docker rm -f loan-mysql loan-redis loan-nacos loan-gateway loan-am loan-cp loan-file loan-crm-frontend loan-cp-frontend 2>/dev/null || true
docker rm -f maven-builder crm-frontend-builder cp-frontend-builder 2>/dev/null || true

# Clean up build artifacts
echo "Cleaning up build artifacts..."
rm -rf target/* 2>/dev/null || true
rm -rf frontend-dist/* 2>/dev/null || true

echo "Cleanup completed successfully!"
