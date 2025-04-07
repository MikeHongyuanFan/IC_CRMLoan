#!/bin/bash
set -e

echo "Building backend services..."

# Remove any existing Maven builder container
echo "Cleaning up any existing Maven builder container..."
docker rm -f maven-builder 2>/dev/null || true

# Create a temporary Docker container to build the backend
echo "Creating Maven container to build the backend..."
docker run --name maven-builder -v $(pwd)/CRM项目/api/crm:/app -v $(pwd)/maven-settings.xml:/root/.m2/settings.xml -w /app maven:3.8-openjdk-8 mvn clean package -DskipTests

# Create target directory if it doesn't exist
mkdir -p target

# Copy the built JAR files from the container to the host
echo "Copying built JAR files..."
docker cp maven-builder:/app/crm-gateway/target/crm-gateway.jar target/ || echo "Warning: Failed to copy crm-gateway.jar"
docker cp maven-builder:/app/crm-am/target/crm-am.jar target/ || echo "Warning: Failed to copy crm-am.jar"
docker cp maven-builder:/app/crm-cp/target/crm-cp.jar target/ || echo "Warning: Failed to copy crm-cp.jar"
docker cp maven-builder:/app/crm-file/target/crm-file.jar target/ || echo "Warning: Failed to copy crm-file.jar"

# Clean up the container
echo "Cleaning up Maven container..."
docker rm maven-builder

# Create simple Dockerfiles for each service
echo "Creating Dockerfiles for backend services..."

cat > CRM项目/api/crm/crm-gateway/Dockerfile << 'DOCKERFILE'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-gateway.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
EXPOSE 30001
ENTRYPOINT ["java", "-jar", "app.jar"]
DOCKERFILE

cat > CRM项目/api/crm/crm-am/Dockerfile << 'DOCKERFILE'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-am.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
DOCKERFILE

cat > CRM项目/api/crm/crm-cp/Dockerfile << 'DOCKERFILE'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-cp.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
DOCKERFILE

cat > CRM项目/api/crm/crm-file/Dockerfile << 'DOCKERFILE'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-file.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
DOCKERFILE

echo "Backend build completed successfully!"
