#!/bin/bash

# Prompt user for SMB details
smb_server="10.10.10.100"
smb_share="HomeServer/Media/Videos"
read -p "Enter your SMB username: " smb_username
read -s -p "Enter your SMB password: " smb_password
echo

# Install cifs-utils
sudo apt-get update
sudo apt-get install -y cifs-utils

# Create a credentials file for SMB authentication
echo "username=$smb_username" > ~/.smbcredentials
echo "password=$smb_password" >> ~/.smbcredentials

# Make the credentials file readable only by the current user
chmod 600 ~/.smbcredentials

# Prompt user for the mount point
read -p "Enter the local directory to mount the SMB share (e.g., /mnt/smb): " mount_point

# Create the mount point if it doesn't exist
sudo mkdir -p $mount_point

# Add the mount command to /etc/fstab for automatic mounting
echo "//${smb_server}/${smb_share} ${mount_point} cifs credentials=/home/$(whoami)/.smbcredentials,uid=$(id -u),gid=$(id -g),file_mode=0777,dir_mode=0777 0 0" | sudo tee -a /etc/fstab

# Mount the SMB share
sudo mount -a

# Install Jellyfin
wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | sudo apt-key add -
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
sudo apt-get update
sudo apt-get install -y jellyfin

# Start and enable Jellyfin service
sudo systemctl enable jellyfin
sudo systemctl start jellyfin

echo "Jellyfin installation and SMB share setup complete."
