# CRM Loan System

This repository contains the CRM Loan System with both backend and frontend components.

## Project Structure

- `CRM项目/api/crm`: Backend services (Spring Boot microservices)
- `CRM项目/web/crm`: Frontend application (Vue.js)
- `CRM项目/web/cp-web`: CP Web frontend application (Vue.js)
- `Calculator`: Loan calculation tools

## Docker Deployment

### Prerequisites

- Docker and Docker Compose installed
- Git repository cloned

### Setup Instructions

1. **Create Dockerfiles for backend services**

   For each backend service (if not already present), create a Dockerfile in its directory:
   
   ```bash
   # Example for crm-gateway, crm-am, crm-cp, and crm-file
   cp backend-dockerfile-template CRM项目/api/crm/crm-gateway/Dockerfile
   cp backend-dockerfile-template CRM项目/api/crm/crm-am/Dockerfile
   cp backend-dockerfile-template CRM项目/api/crm/crm-cp/Dockerfile
   cp backend-dockerfile-template CRM项目/api/crm/crm-file/Dockerfile
   ```

2. **Build and run all services**

   ```bash
   # Build the backend services first
   cd CRM项目/api/crm
   mvn clean package -DskipTests
   
   # Return to the root directory and start all services
   cd /path/to/project/root
   docker-compose up -d
   ```

3. **Access the applications**

   - CRM Frontend: http://localhost:9527
   - CP Frontend: http://localhost:9528
   - API Gateway: http://localhost:30001
   - Nacos Console: http://localhost:8848/nacos (user: nacos, password: nacos)

### Service Dependencies

- MySQL database (port 3306)
- Redis (port 6379)
- Nacos service registry (port 8848)
- Backend microservices
  - crm-gateway
  - crm-am
  - crm-cp
  - crm-file
- Frontend applications
  - crm-frontend
  - cp-frontend

## Manual Deployment

If you prefer to deploy services individually:

### Backend Services

1. Start infrastructure services:
   ```bash
   docker-compose up -d mysql redis nacos
   ```

2. Build and run each service:
   ```bash
   cd CRM项目/api/crm
   mvn clean package -DskipTests
   
   # Run each service
   java -jar crm-gateway/target/*.jar --spring.profiles.active=prod
   java -jar crm-am/target/*.jar --spring.profiles.active=prod
   java -jar crm-cp/target/*.jar --spring.profiles.active=prod
   java -jar crm-file/target/*.jar --spring.profiles.active=prod
   ```

### Frontend Applications

1. Build the frontend:
   ```bash
   cd CRM项目/web/crm
   npm install
   npm run build
   
   cd ../cp-web
   npm install
   npm run build
   ```

2. Deploy using Nginx:
   ```bash
   # For CRM frontend
   docker build -t crm-frontend -f docker/Dockerfile .
   docker run -d -p 9527:80 --name crm-frontend crm-frontend
   
   # For CP frontend
   cd ../cp-web
   docker build -t cp-frontend -f docker/Dockerfile .
   docker run -d -p 9528:80 --name cp-frontend cp-frontend
   ```

## Troubleshooting

- If services fail to start, check logs with `docker-compose logs [service_name]`
- Ensure all required ports are available
- Verify network connectivity between containers
