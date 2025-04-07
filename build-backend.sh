#!/bin/bash
set -e

echo "Building backend services..."

# Create a temporary Docker container to build the backend
docker run --rm -v $(pwd)/CRM项目/api/crm:/app -w /app maven:3.8-openjdk-8 mvn clean package -DskipTests

# Create target directory if it doesn't exist
mkdir -p target

# Copy the built JAR files to the appropriate locations
echo "Copying built JAR files..."
cp CRM项目/api/crm/crm-gateway/target/*.jar target/crm-gateway.jar
cp CRM项目/api/crm/crm-am/target/*.jar target/crm-am.jar
cp CRM项目/api/crm/crm-cp/target/*.jar target/crm-cp.jar
cp CRM项目/api/crm/crm-file/target/*.jar target/crm-file.jar

# Update Dockerfiles to use the pre-built JAR files
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

echo "Starting backend services..."
docker-compose up -d crm-gateway crm-am crm-cp crm-file
