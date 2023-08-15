#!/bin/bash

# Change to the /tmp directory
cd /tmp

# Download the Kasm release archive
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.13.1.421524.tar.gz

# Extract the Kasm release archive
tar -xf kasm_release_1.13.1.421524.tar.gz

# Run the installation script with sudo
sudo bash kasm_release/install.sh -y
