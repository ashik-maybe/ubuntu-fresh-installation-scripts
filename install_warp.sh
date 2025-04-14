#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Check if Cloudflare Warp is installed
if is_installed "cloudflare-warp"; then
    echo "Cloudflare WARP is already installed."
    exit 0
fi

# Prompt user for installation
read -p "Cloudflare WARP is not installed. Do you want to install it? (y/n): " choice
if [[ "$choice" != "y" ]]; then
    echo "Installation aborted."
    exit 0
fi

# Add Cloudflare GPG key
if ! curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg; then
    echo "Failed to add Cloudflare GPG key."
    exit 1
fi

# Add the repository to your apt repositories
if ! echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list; then
    echo "Failed to add Cloudflare repository."
    exit 1
fi

# Install Cloudflare Warp
if ! sudo apt-get update && sudo apt-get install -y cloudflare-warp; then
    echo "Failed to install Cloudflare WARP."
    exit 1
fi

# Echo guide for using WARP
echo "Cloudflare WARP has been installed."
echo "Quick Guide to Using WARP:"
echo "1. Register the client: warp-cli registration new"
echo "2. Connect: warp-cli connect"
echo "3. Verify connection: curl https://www.cloudflare.com/cdn-cgi/trace/ (check for warp=on)"
echo "4. Switching modes: Use 'warp-cli mode --help' for options."
echo "   - DNS only mode: warp-cli mode doh"
echo "   - WARP with DoH: warp-cli mode warp+doh"
echo "5. Using 1.1.1.1 for Families:"
echo "   - Families mode off: warp-cli dns families off"
echo "   - Malware protection: warp-cli dns families malware"
echo "   - Malware and adult content: warp-cli dns families full"
