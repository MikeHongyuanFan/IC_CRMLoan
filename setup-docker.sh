#!/bin/bash

# Exit on error
set -e

echo "Setting up Docker environment for CRM Loan System..."

# Create Dockerfiles for backend services
echo "Creating Dockerfiles for backend services..."
cp backend-dockerfile-template CRM项目/api/crm/crm-gateway/Dockerfile
cp backend-dockerfile-template CRM项目/api/crm/crm-am/Dockerfile
cp backend-dockerfile-template CRM项目/api/crm/crm-cp/Dockerfile
cp backend-dockerfile-template CRM项目/api/crm/crm-file/Dockerfile

# Check if cp-web has a Dockerfile, if not create one
if [ ! -f "CRM项目/web/cp-web/docker/Dockerfile" ]; then
  echo "Creating Dockerfile for CP Web frontend..."
  mkdir -p CRM项目/web/cp-web/docker
  cat > CRM项目/web/cp-web/docker/Dockerfile << 'EOF'
FROM nginx 

COPY ./dist /data

RUN rm /etc/nginx/conf.d/default.conf

ADD cp-web.conf /etc/nginx/conf.d/
EXPOSE 9528
RUN /bin/bash -c 'echo init ok'
EOF

  # Create Nginx config for CP Web
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
fi

# Update CRM frontend Nginx config to use container name instead of IP
echo "Updating CRM frontend Nginx configuration..."
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

echo "Setup complete! You can now build and run the services with:"
echo "1. Build backend services: cd CRM项目/api/crm && mvn clean package -DskipTests"
echo "2. Build frontend: cd CRM项目/web/crm && npm install && npm run build"
echo "3. Build CP frontend: cd CRM项目/web/cp-web && npm install && npm run build"
echo "4. Start all services: docker-compose up -d"
