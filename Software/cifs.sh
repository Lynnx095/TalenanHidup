#!/bin/bash

# Prompt user for SMB server details
read -p "Enter SMB server address: " smb_server
read -p "Enter SMB share name: " smb_share
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
