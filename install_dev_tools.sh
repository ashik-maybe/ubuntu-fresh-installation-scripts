#!/bin/bash

set -euo pipefail

is_installed() {
    command -v "$1" &>/dev/null
}

echo "📦 Updating APT and installing base tools..."
sudo apt-get update
sudo apt-get install -y wget gpg apt-transport-https curl gnupg

# --- GitHub Desktop ---
if is_installed "github-desktop"; then
    echo "✅ GitHub Desktop is already installed."
else
    echo "🔧 Installing GitHub Desktop..."
    wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" | sudo tee /etc/apt/sources.list.d/mwt-desktop.list
    sudo apt-get update
    sudo apt-get install -y github-desktop
    echo "✅ GitHub Desktop installed."
fi

# --- Visual Studio Code ---
if is_installed "code"; then
    echo "✅ Visual Studio Code is already installed."
else
    echo "🔧 Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    rm -f packages.microsoft.gpg
    sudo apt-get update
    sudo apt-get install -y code
    echo "✅ Visual Studio Code installed."
fi

echo "🎉 Developer tools setup complete."
