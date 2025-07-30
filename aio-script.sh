#!/bin/bash

#================================================================================
# All-in-One (AIO) Installer Script
#================================================================================

# --- Application Definitions ---
# Use arrays to store the details of each script for easier management.

# Display names for the menu
APP_NAMES=(
    "WireGuard (by angristan)"
    "AdGuard Home + DoH (by Lynnx095)"
    "Docker CE (by Lynnx095)"
    "Jellyfin Server (by Lynnx095)"
    "Kasm Workspaces (by Lynnx095)"
    "CIFS/Samba Share (by Lynnx095)"
    "Cloudflare Warp (by Lynnx095)"
    "Portainer (by Lynnx095)"
)

# URLs for the scripts - CORRECTED
APP_URLS=(
    "https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/adguard-doh-script.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/docker.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/jellyfin.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/kasm.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/cifs.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/vpn.sh"
    "https://raw.githubusercontent.com/Lynnx095/TalenanHidup/main/Software/portainer.sh"
)

# Local filenames for the downloaded scripts
APP_FILES=(
    "wireguard-install.sh"
    "adguard-doh-script.sh"
    "docker-install.sh"
    "jellyfin-install.sh"
    "kasm-install.sh"
    "cifs-install.sh"
    "vpn-install.sh"
    "portainer-install.sh"
)

# --- Functions ---

# Function to print colored text for better user experience
print_color() {
    case "$1" in
        "green") echo -e "\n\e[32m$2\e[0m\n" ;;
        "red")   echo -e "\n\e[31m$2\e[0m\n" ;;
        "yellow") echo -e "\n\e[33m$2\e[0m\n" ;;
        "blue")  echo -e "\n\e[34m$2\e[0m\n" ;;
        *)       echo "$2" ;;
    esac
}

# Function to download, set permissions, and execute a script
run_script() {
    local url="$1"
    local filename="$2"
    local app_name="$3"

    print_color "blue" "Downloading script for $app_name..."
    if ! curl -L -o "$filename" "$url"; then
        print_color "red" "Failed to download the script from $url."
        return 1
    fi

    # Check if the downloaded file is an HTML page (like a 404 error)
    if grep -q "<html>" "$filename"; then
        print_color "red" "Error: Downloaded file appears to be an HTML error page (like 404 Not Found), not a script. Please check the URL."
        rm "$filename"
        return 1
    fi

    print_color "blue" "Setting execute permissions for $filename..."
    if ! chmod +x "$filename"; then
        print_color "red" "Failed to set execute permissions on $filename."
        return 1
    fi

    print_color "green" "Executing $filename..."
    echo "--------------------------------------------------"
    ./"$filename"
    echo "--------------------------------------------------"
    print_color "green" "Execution of $filename has finished."
    
    read -p "Do you want to remove the downloaded script ($filename)? [y/N]: " remove_choice
    if [[ "$remove_choice" =~ ^[Yy]$ ]]; then
        rm "$filename"
        print_color "yellow" "$filename has been removed."
    fi
}

# Function to display the application selection menu
show_app_menu() {
    local mode=$1 # "Install" or "Remove"
    echo "========================================"
    print_color "green" "$mode Applications"
    echo "========================================"
    echo "Select one or more applications."
    echo "Enter numbers separated by spaces (e.g., 1 3 5)."
    echo ""
    
    for i in "${!APP_NAMES[@]}"; do
        printf "   %-2s) %s\n" "$((i+1))" "${APP_NAMES[$i]}"
    done
    
    echo "   b) Back to Main Menu"
    echo "========================================"
}

# Function to process user's selection for batch operations
process_selection() {
    local mode=$1
    show_app_menu "$mode"
    read -p "Enter your choice(s): " selections

    if [[ "$selections" == "b" || "$selections" == "B" ]]; then
        return
    fi

    for choice in $selections; do
        # Validate that choice is a number and within bounds
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#APP_NAMES[@]}" ]; then
            index=$((choice-1))
            app_name="${APP_NAMES[$index]}"
            app_url="${APP_URLS[$index]}"
            app_file="${APP_FILES[$index]}"
            
            print_color "yellow" "--- Starting $mode process for: $app_name ---"
            run_script "$app_url" "$app_file" "$app_name"
            print_color "yellow" "--- Finished $mode process for: $app_name ---"
            read -p "Press [Enter] to continue to the next selection (if any)..."
        else
            print_color "red" "Invalid selection: $choice. It will be skipped."
            sleep 2
        fi
    done
}

# --- Main Script Logic ---

# Check if the script is run as root, as the sub-scripts often require it
if [[ $EUID -ne 0 ]]; then
   print_color "red" "This script must be run as root. Please use 'sudo ./script_name.sh'"
   exit 1
fi

# Check for curl dependency
if ! command -v curl &> /dev/null; then
    print_color "red" "Error: 'curl' is not installed. Please install it to continue."
    exit 1
fi

# Main loop to show the menu until the user exits
while true; do
    clear
    echo "========================================"
    print_color "green" "AIO Installer Main Menu"
    echo "========================================"
    echo "   1) Install Applications (Batch Mode)"
    echo "   2) Remove Applications (Re-runs script for uninstall option)"
    echo "   3) Exit"
    echo "========================================"
    read -p "Enter your choice [1-3]: " main_choice

    case $main_choice in
        1)
            process_selection "Install"
            read -p "Press [Enter] to return to the main menu..."
            ;;
        2)
            print_color "yellow" "Note: This will re-run the installer script. Look for an 'uninstall' or 'remove' option within the script itself."
            read -p "Press [Enter] to continue..."
            process_selection "Remove"
            read -p "Press [Enter] to return to the main menu..."
            ;;
        3)
            print_color "green" "Exiting. Goodbye!"
            break
            ;;
        *)
            print_color "red" "Invalid option. Please select a number between 1 and 3."
            sleep 2
            ;;
    esac
done
