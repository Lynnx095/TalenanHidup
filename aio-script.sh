#!/bin/bash

#================================================================================
# All-in-One (AIO) Installer Script
#================================================================================

# --- Script URLs ---
WIREGUARD_URL="https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh"
ADGUARD_DOH_URL="https://raw.githubusercontent.com/Lynnx095/TalenanHidup/refs/heads/main/Software/adguard-doh-script.sh"

# --- Local Filenames ---
WIREGUARD_SCRIPT="wireguard-install.sh"
ADGUARD_DOH_SCRIPT="adguard-doh-script.sh"


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

    print_color "blue" "Downloading $filename..."
    # Use curl to download the script. The -O flag saves it with the remote name.
    if ! curl -L -o "$filename" "$url"; then
        print_color "red" "Failed to download the script from $url. Please check the URL and your internet connection."
        return 1
    fi

    print_color "blue" "Setting execute permissions for $filename..."
    # Make the downloaded script executable
    if ! chmod +x "$filename"; then
        print_color "red" "Failed to set execute permissions on $filename."
        return 1
    fi

    print_color "green" "Executing $filename..."
    echo "--------------------------------------------------"
    # Execute the script
    ./"$filename"
    echo "--------------------------------------------------"
    print_color "green" "Execution of $filename has finished."
    # Ask user if they want to remove the downloaded script
    read -p "Do you want to remove the downloaded script ($filename)? [y/N]: " remove_choice
    if [[ "$remove_choice" =~ ^[Yy]$ ]]; then
        rm "$filename"
        print_color "yellow" "$filename has been removed."
    fi
}

# Function to display the main menu
show_menu() {
    echo "========================================"
    print_color "green" "AIO Installer Menu"
    echo "========================================"
    echo "Please choose which script you want to run:"
    echo "   1) Install WireGuard (by angristan)"
    echo "   2) Install AdGuard Home + DoH (by Lynnx095)"
    echo "   3) Exit"
    echo "========================================"
}

# --- Main Script Logic ---

# Check if the script is run as root, as the sub-scripts require it
if [[ $EUID -ne 0 ]]; then
   print_color "red" "This script must be run as root. Please use 'sudo ./script_name.sh'"
   exit 1
fi

# Check for curl dependency
if ! command -v curl &> /dev/null; then
    print_color "red" "Error: 'curl' is not installed. Please install it to continue."
    print_color "yellow" "On Debian/Ubuntu: sudo apt update && sudo apt install curl"
    print_color "yellow" "On CentOS/RHEL: sudo yum install curl"
    exit 1
fi


# Main loop to show the menu until the user exits
while true; do
    show_menu
    read -p "Enter your choice [1-3]: " choice

    case $choice in
        1)
            run_script "$WIREGUARD_URL" "$WIREGUARD_SCRIPT"
            read -p "Press [Enter] to return to the menu..."
            ;;
        2)
            run_script "$ADGUARD_DOH_URL" "$ADGUARD_DOH_SCRIPT"
            read -p "Press [Enter] to return to the menu..."
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
