#!/bin/bash

#================================================================================
# AdGuard Home & DNS-over-HTTPS (DoH) Installer
#================================================================================

# --- Functions ---

# Function to print colored text
print_color() {
    case "$1" in
        "green") echo -e "\n\033[0;32m$2\033[0m\n" ;;
        "red") echo -e "\n\033[0;31m$2\033[0m\n" ;;
        "yellow") echo -e "\n\033[0;33m$2\033[0m\n" ;;
        *) echo "$2" ;;
    esac
}

# Function to check for required commands
check_dependencies() {
    local missing_deps=()
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_color "red" "Error: Required command(s) not found: ${missing_deps[*]}. Please install them and rerun the script."
        print_color "yellow" "On Debian/Ubuntu, use: sudo apt update && sudo apt install -y curl jq"
        print_color "yellow" "On CentOS/RHEL, use: sudo yum install -y curl jq"
        exit 1
    fi
}

# --- Main Script ---

# 1. Preliminary Checks
#-------------------------------------------------
print_color "green" "Starting AdGuard Home & DoH setup..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_color "red" "This script must be run as root. Please use 'sudo'."
   exit 1
fi

# Check for dependencies
check_dependencies

# 2. Gather User Input
#-------------------------------------------------
print_color "yellow" "Please provide your details below."

read -p "Enter your domain name (e.g., dns.example.com): " DOMAIN_NAME
read -p "Enter your email address (for SSL certificate): " EMAIL
read -sp "Enter your Cloudflare API Token: " CLOUDFLARE_DNS_API_TOKEN
echo

if [[ -z "$DOMAIN_NAME" || -z "$EMAIL" || -z "$CLOUDFLARE_DNS_API_TOKEN" ]]; then
    print_color "red" "Domain name, email, and Cloudflare API token cannot be empty. Aborting."
    exit 1
fi

# 3. Install AdGuard Home
#-------------------------------------------------
print_color "green" "Installing AdGuard Home..."
if curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v; then
    print_color "green" "AdGuard Home installed successfully."
else
    print_color "red" "AdGuard Home installation failed. Aborting."
    exit 1
fi

# 4. Configure Cloudflare DNS 'A' Record
#-------------------------------------------------
print_color "green" "Configuring Cloudflare DNS..."
VPS_IP=$(curl -s https://api.ipify.org)
if [[ -z "$VPS_IP" ]]; then
    print_color "red" "Could not determine the public IP address of the server. Aborting."
    exit 1
fi

print_color "yellow" "Server Public IP detected: $VPS_IP"

# Extract the base domain to find the Zone ID
BASE_DOMAIN=$(echo "$DOMAIN_NAME" | awk -F. '{print $(NF-1)"."$NF}')

# Get Cloudflare Zone ID
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$BASE_DOMAIN" \
     -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

if [[ -z "$ZONE_ID" || "$ZONE_ID" == "null" ]]; then
    print_color "red" "Could not get Cloudflare Zone ID. Please check your domain name and API token. Aborting."
    exit 1
fi

print_color "green" "Cloudflare Zone ID found: $ZONE_ID"

# Create DNS A Record
CREATE_DNS_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CLOUDFLARE_DNS_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'"$DOMAIN_NAME"'","content":"'"$VPS_IP"'","ttl":120,"proxied":false}')

if [[ $(echo "$CREATE_DNS_RESPONSE" | jq -r '.success') == "true" ]]; then
    print_color "green" "Successfully created DNS 'A' record for $DOMAIN_NAME pointing to $VPS_IP."
else
    # Check if the record already exists
    if [[ $(echo "$CREATE_DNS_RESPONSE" | jq -r '.errors[0].code') == "81057" ]]; then
        print_color "yellow" "DNS 'A' record already exists. No action needed."
    else
        print_color "red" "Failed to create DNS 'A' record. Error: $(echo $CREATE_DNS_RESPONSE | jq -r '.errors[0].message'). Aborting."
        exit 1
    fi
fi

# 5. Obtain and Install SSL Certificate
#-------------------------------------------------
print_color "green" "Setting up SSL certificate with lego..."

# Using the automated script from the guide
mkdir -p /opt/lego
curl -s https://raw.githubusercontent.com/Lynnx095/TalenanHidup/refs/heads/main/Software/legoagh --output /opt/lego/lego.sh
chmod +x /opt/lego/lego.sh

# Run the lego script with the user's variables
if DOMAIN_NAME="$DOMAIN_NAME" \
    EMAIL="$EMAIL" \
    DNS_PROVIDER="cloudflare" \
    CLOUDFLARE_DNS_API_TOKEN="$CLOUDFLARE_DNS_API_TOKEN" \
    /opt/lego/lego.sh; then
    print_color "green" "SSL certificate setup successful."
else
    print_color "red" "SSL certificate setup failed. Please check the logs."
    exit 1
fi

# 6. Final Steps
#-------------------------------------------------
print_color "green" "Restarting AdGuard Home to apply all changes..."
systemctl restart AdGuardHome

print_color "green" "✅ Setup Complete!"
print_color "yellow" "IMPORTANT FINAL STEP:"
echo -e "1. Open your web browser and navigate to \033[0;33mhttp://$VPS_IP:3000\033[0m"
echo "2. Complete the initial AdGuard Home setup (create your admin username and password)."
echo "3. After setup, AdGuard Home will be accessible securely at \033[0;33mhttps://$DOMAIN_NAME\033[0m"
echo "Your DNS-over-HTTPS URL is: \033[0;33mhttps://$DOMAIN_NAME/dns-query\033[0m"
echo "The SSL certificate will be renewed automatically."
