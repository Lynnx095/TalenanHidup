#!/bin/bash

# Install Docker
echo "Installing Docker..."

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add your current user to the docker group
usermod -aG docker $USER

# Enable Docker service to start on boot
systemctl enable docker

# Display Docker version and info
docker --version
docker info

# Install Docker Compose
echo "Installing Docker Compose..."

# Set the version of Docker Compose to install
DOCKER_COMPOSE_VERSION="1.29.2"  # Update this to the latest stable version if needed

# Download Docker Compose binary
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose

# Apply executable permissions to the Docker Compose binary
chmod +x /usr/local/bin/docker-compose

# Create symbolic link to allow Docker Compose to be run from anywhere
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify Docker Compose installation
docker-compose --version

echo "Docker and Docker Compose installation completed successfully."
