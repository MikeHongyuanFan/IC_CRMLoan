#!/bin/bash

# Exit on error
set -e

echo "Starting local deployment of CRM Loan System..."

# Step 1: Run the setup script to prepare Docker files
echo "Step 1: Setting up Docker files..."
./setup-docker.sh

# Step 2: Build the applications using Docker containers
echo "Step 2: Building applications using Docker..."
docker-compose -f docker-compose-build.yaml up

# Step 3: Start all services
echo "Step 3: Starting all services..."
docker-compose up -d

echo "Deployment complete! Services are starting up."
echo "You can access the applications at:"
echo "- CRM Frontend: http://localhost:9527"
echo "- CP Frontend: http://localhost:9528"
echo "- API Gateway: http://localhost:30001"
echo "- Nacos Console: http://localhost:8848/nacos (user: nacos, password: nacos)"
echo ""
echo "To check service status: docker-compose ps"
echo "To view logs: docker-compose logs -f [service_name]"
