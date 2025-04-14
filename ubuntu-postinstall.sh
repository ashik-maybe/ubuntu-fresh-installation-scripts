#!/bin/bash
# ubuntu-postinstall.sh — Post-install automation for Ubuntu and derivatives

set -euo pipefail

# Ask for sudo up front
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "🚀 Ubuntu Post-Install Script Starting..."

# 0. Ask user whether to run APT optimization
if ! grep -q 'Queue-Mode' /etc/apt/apt.conf.d/99apt-optimized 2>/dev/null; then
    read -p "🛠 Do you want to optimize APT performance? (y/n): " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        echo "🔧 Running APT optimization script..."
        ./optimize-apt.sh
    else
        echo "⏩ Skipping APT optimization."
    fi
else
    echo "✅ APT already optimized. Skipping."
fi

# 1. Remove Snap-based Firefox
echo "🧹 Removing Snap-based Firefox..."
if snap list firefox >/dev/null 2>&1; then
    sudo snap remove --purge firefox && echo "✅ Firefox Snap removed."
else
    echo "ℹ️ Firefox Snap not installed. Skipping."
fi

# 2. Install Flatpak and Flatseal
echo "📦 Installing Flatpak ecosystem..."
if ! command -v flatpak >/dev/null 2>&1; then
    sudo apt install -y flatpak
    echo "✅ Flatpak installed."
else
    echo "ℹ️ Flatpak already installed."
fi

if ! flatpak remotes | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "✅ Flathub remote added."
else
    echo "ℹ️ Flathub already configured."
fi

if ! flatpak list | grep -q com.github.tchx84.Flatseal; then
    flatpak install -y flathub com.github.tchx84.Flatseal
    echo "✅ Flatseal installed."
else
    echo "ℹ️ Flatseal already installed."
fi

# 3. Enable Universe repo and upgrade system
echo "🛠 Enabling Universe repository..."
sudo add-apt-repository -y universe
sudo apt update && sudo apt -y upgrade
echo "✅ Universe repo enabled and system upgraded."

# 4. Install Brave Browser via official script
echo "🌐 Checking for Brave Browser..."
if ! command -v brave-browser >/dev/null 2>&1; then
    echo "📥 Installing Brave Browser via official script..."
    curl -fsS https://dl.brave.com/install.sh | sh
    echo "✅ Brave Browser installed."
else
    echo "ℹ️ Brave Browser already present."
fi

# 5. Install ubuntu-restricted-extras
echo "🎞 Installing multimedia codecs..."
if ! dpkg -l | grep -qw ubuntu-restricted-extras; then
    sudo apt install -y ubuntu-restricted-extras
    echo "✅ ubuntu-restricted-extras installed."
else
    echo "ℹ️ ubuntu-restricted-extras already installed."
fi

# 6. Install GNOME-specific tools if running GNOME
echo "🧠 Checking for GNOME Desktop..."
if [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ]; then
    echo "🔍 GNOME detected. Installing Tweaks and Extension Manager..."

    if ! dpkg -l | grep -qw gnome-tweaks; then
        sudo apt install -y gnome-tweaks && echo "✅ GNOME Tweaks installed."
    else
        echo "ℹ️ GNOME Tweaks already installed."
    fi

    if ! flatpak list | grep -q com.mattjakeman.ExtensionManager; then
        flatpak install -y flathub com.mattjakeman.ExtensionManager
        echo "✅ Extension Manager installed."
    else
        echo "ℹ️ Extension Manager already installed."
    fi
else
    echo "❌ GNOME not detected. Skipping GNOME-specific tools."
fi

echo "🎯 All tasks complete!"
