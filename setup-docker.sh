#!/bin/bash

# Exit on error
set -e

echo "Setting up Docker environment for CRM Loan System..."

# Create directories for backend services if they don't exist
mkdir -p CRM项目/api/crm/crm-gateway
mkdir -p CRM项目/api/crm/crm-am
mkdir -p CRM项目/api/crm/crm-cp
mkdir -p CRM项目/api/crm/crm-file

# Create directories for frontend services if they don't exist
mkdir -p CRM项目/web/crm/docker
mkdir -p CRM项目/web/cp-web/docker

# Create Dockerfiles for backend services
echo "Creating Dockerfiles for backend services..."

cat > CRM项目/api/crm/crm-gateway/Dockerfile << 'EOF'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-gateway.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
EXPOSE 30001
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > CRM项目/api/crm/crm-am/Dockerfile << 'EOF'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-am.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > CRM项目/api/crm/crm-cp/Dockerfile << 'EOF'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-cp.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

cat > CRM项目/api/crm/crm-file/Dockerfile << 'EOF'
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ../../../../../../target/crm-file.jar app.jar
ENV SPRING_PROFILES_ACTIVE=prod
ENV loan.nacos.addr=loan-nacos-url
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Create Nginx config for CRM frontend
echo "Creating Nginx configuration for CRM frontend..."
cat > CRM项目/web/crm/docker/aus-crm.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    # 打包好的dist目录文件，放置到这个目录下
    root /data/;

    location / {
          if (!-e $request_filename) {
              rewrite ^(.*)$ /index.html?s=$1 last;
              break;
          }
      }
    # 注意维护新增微服务，gateway 路由前缀
    location ~* ^/(crm-am-api|crm-cp-api) {
       proxy_pass http://crm-gateway:30001;
       proxy_connect_timeout 15s;
       proxy_send_timeout 15s;
       proxy_read_timeout 15s;
       proxy_set_header X-Forwarded-Proto http;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Create Dockerfile for CRM frontend
cat > CRM项目/web/crm/docker/Dockerfile << 'EOF'
FROM nginx:alpine
COPY ../../../frontend-dist/crm /data
RUN rm /etc/nginx/conf.d/default.conf
COPY docker/aus-crm.conf /etc/nginx/conf.d/
EXPOSE 80
EOF

# Create Nginx config for CP frontend
echo "Creating Nginx configuration for CP frontend..."
cat > CRM项目/web/cp-web/docker/cp-web.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    # 打包好的dist目录文件，放置到这个目录下
    root /data/;

    location / {
          if (!-e $request_filename) {
              rewrite ^(.*)$ /index.html?s=$1 last;
              break;
          }
      }
    # 注意维护新增微服务，gateway 路由前缀
    location ~* ^/(crm-am-api|crm-cp-api) {
       proxy_pass http://crm-gateway:30001;
       proxy_connect_timeout 15s;
       proxy_send_timeout 15s;
       proxy_read_timeout 15s;
       proxy_set_header X-Forwarded-Proto http;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Create Dockerfile for CP frontend
cat > CRM项目/web/cp-web/docker/Dockerfile << 'EOF'
FROM nginx:alpine
COPY ../../../frontend-dist/cp-web /data
RUN rm /etc/nginx/conf.d/default.conf
COPY docker/cp-web.conf /etc/nginx/conf.d/
EXPOSE 80
EOF

echo "Setup complete!"
