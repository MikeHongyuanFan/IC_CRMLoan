#!/bin/bash

# Exit on error
set -e

echo "Starting local deployment of CRM Loan System..."

# Step 1: Run the setup script to prepare Docker files
echo "Step 1: Setting up Docker files..."
./setup-docker.sh

# Step 2: Start infrastructure services first
echo "Step 2: Starting infrastructure services..."
docker-compose up -d redis mysql nacos

# Wait for infrastructure services to be ready
echo "Waiting for infrastructure services to be ready..."
sleep 30

# Step 3: Build and start backend services
echo "Step 3: Building and starting backend services..."
./build-backend.sh

# Step 4: Build and start frontend services
echo "Step 4: Building and starting frontend services..."
./build-frontend.sh

echo "Deployment complete! Services are starting up."
echo "You can access the applications at:"
echo "- CRM Frontend: http://localhost:9527"
echo "- CP Frontend: http://localhost:9528"
echo "- API Gateway: http://localhost:30001"
echo "- Nacos Console: http://localhost:8848/nacos (user: nacos, password: nacos)"
echo ""
echo "To check service status: docker-compose ps"
echo "To view logs: docker-compose logs -f [service_name]"
