#!/bin/bash

set -e

echo "--- Preparing for installation by removing older versions ---"
# Uninstall any conflicting packages.
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  if dpkg -l | grep -q $pkg; then
    echo "Removing conflicting package: $pkg"
    sudo apt-get remove -y $pkg
  fi
done

# --- Step 1: Set up Docker's APT repository ---
echo "--- Step 1: Setting up Docker's repository ---"

# Update package lists and install dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Step 2: Install Docker packages ---
echo "--- Step 2: Installing Docker Engine and Docker Compose ---"

# Update package lists again to include the new Docker repo
sudo apt-get update

# Install the latest versions
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Step 3: Post-installation configuration ---
echo "--- Step 3: Configuring user and services ---"

# Add your current user to the 'docker' group to run Docker without sudo
sudo usermod -aG docker $USER

# Enable Docker service to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# --- Step 4: Verify the installation ---
echo "--- Step 4: Verifying installation ---"

echo "Docker version:"
docker --version

echo "Docker Compose version:"
# Note: The command is 'docker compose' (with a space), not 'docker-compose'
docker compose version

echo "✅ Docker and Docker Compose installation completed."
echo "💡 IMPORTANT: You must log out and log back in for the user group changes to take effect."
echo "After logging back in, you can run 'docker run hello-world' to test your installation."
