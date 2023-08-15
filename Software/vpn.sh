#!/bin/bash

# Import Cloudflare Warp GPG key
curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

# Add Cloudflare Warp repository to sources
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

# Update package lists
sudo apt-get update

# Install Cloudflare Warp
sudo apt-get install cloudflare-warp -y

# Registering Device
warp-cli register

# Turning On VPN
warp-cli connect