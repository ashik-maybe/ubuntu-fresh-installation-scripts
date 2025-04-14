#!/bin/bash
# ubuntu-postinstall.sh — Post-install automation for Ubuntu and derivatives

set -euo pipefail
sudo -v

echo "🚀 Starting Ubuntu post-install tasks..."

# 0. APT optimization (optional)
if ! grep -q 'Queue-Mode' /etc/apt/apt.conf.d/99apt-optimized 2>/dev/null; then
    read -p "Optimize APT performance? (y/n): " ans
    [[ "$ans" =~ ^[Yy]$ ]] && ./optimize-apt.sh || echo "Skipped APT optimization."
else
    echo "APT already optimized."
fi

# 1. Remove Snap-based Firefox
if snap list firefox >/dev/null 2>&1; then
    sudo snap remove --purge firefox
    echo "Removed Snap Firefox."
fi

# 2. Flatpak, Flathub, Flatseal
if ! command -v flatpak >/dev/null 2>&1; then
    sudo apt update || sudo apt update --fix-missing
    sudo apt install -y flatpak
fi

if ! flatpak remotes | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

if ! flatpak list | grep -q com.github.tchx84.Flatseal; then
    flatpak install -y flathub com.github.tchx84.Flatseal
fi

# 3. Universe repo + upgrade
sudo add-apt-repository -y universe
sudo apt update || sudo apt update --fix-missing
sudo apt -y upgrade

# 4. Brave Browser
if ! command -v brave-browser >/dev/null 2>&1; then
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# 5. Multimedia support
if ! dpkg -l | grep -qw ubuntu-restricted-extras; then
    sudo apt install -y ubuntu-restricted-extras
fi

# 6. GNOME-specific tools (ask before installing)
if [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ]; then
    read -p "GNOME detected. Install Tweaks & Extension Manager? (y/n): " gnome_ans
    if [[ "$gnome_ans" =~ ^[Yy]$ ]]; then
        if ! dpkg -l | grep -qw gnome-tweaks; then
            sudo apt install -y gnome-tweaks
        fi
        if ! flatpak list | grep -q com.mattjakeman.ExtensionManager; then
            flatpak install -y flathub com.mattjakeman.ExtensionManager
        fi
    else
        echo "Skipped GNOME tools."
    fi
fi

echo "✅ Done."
