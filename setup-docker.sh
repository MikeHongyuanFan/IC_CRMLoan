#!/bin/bash
set -e

echo "Setting up Docker environment..."

# Create directories if they don't exist
mkdir -p target
mkdir -p frontend-dist/crm
mkdir -p frontend-dist/cp-web

# Create Maven settings file if it doesn't exist
if [ ! -f maven-settings.xml ]; then
  cat > maven-settings.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <mirrors>
    <!-- Use Maven Central instead of Aliyun -->
    <mirror>
      <id>maven-central</id>
      <mirrorOf>central</mirrorOf>
      <name>Maven Central</name>
      <url>https://repo.maven.apache.org/maven2</url>
    </mirror>
  </mirrors>
  
  <profiles>
    <profile>
      <id>default</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo.maven.apache.org/maven2</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>https://repo.maven.apache.org/maven2</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
  
  <activeProfiles>
    <activeProfile>default</activeProfile>
  </activeProfiles>
</settings>
XML
  echo "Created Maven settings file."
fi

echo "Docker environment setup completed."
