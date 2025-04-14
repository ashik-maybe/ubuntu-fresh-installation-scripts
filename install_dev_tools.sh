#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Check if GitHub Desktop is installed
if is_installed "github-desktop"; then
    echo "GitHub Desktop is already installed."
else
    # Prompt user for installation
    read -p "GitHub Desktop is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        # Install required packages
        sudo apt-get install -y wget gpg apt-transport-https

        # Add GitHub Desktop GPG key and repository
        if ! wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg > /dev/null; then
            echo "Failed to add GitHub Desktop GPG key."
            exit 1
        fi
        if ! sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'; then
            echo "Failed to add GitHub Desktop repository."
            exit 1
        fi

        # Install GitHub Desktop
        if ! sudo apt update && sudo apt install -y github-desktop; then
            echo "Failed to install GitHub Desktop."
            exit 1
        fi
    fi
fi

# Check if Visual Studio Code is installed
if is_installed "code"; then
    echo "Visual Studio Code is already installed."
else
    # Prompt user for installation
    read -p "Visual Studio Code is not installed. Do you want to install it? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        # Install required packages
        sudo apt-get install -y wget gpg apt-transport-https

        # Add Visual Studio Code GPG key and repository
        if ! wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; then
            echo "Failed to download Visual Studio Code GPG key."
            exit 1
        fi
        if ! sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg; then
            echo "Failed to install Visual Studio Code GPG key."
            exit 1
        fi
        if ! echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null; then
            echo "Failed to add Visual Studio Code repository."
            exit 1
        fi
        rm -f packages.microsoft.gpg

        # Install Visual Studio Code
        if ! sudo apt update && sudo apt install -y code; then
            echo "Failed to install Visual Studio Code."
            exit 1
        fi
    fi
fi
