#!/bin/bash
# ubuntu-postinstall.sh — Clean post-install script for Ubuntu & derivatives

set -euo pipefail
sudo -v

echo "🔧 You can speed up downloads by switching to a local mirror via:"
echo "    → 'Software & Updates' → 'Download from:' → 'Other...' → 'Select Best Server'"
read -p "Have you switched to a local mirror? (y/n): " _

echo "🛠 Step 0: Enabling universe repo & updating package lists..."
if ! grep -Rq "^deb .* universe" /etc/apt/; then
    sudo add-apt-repository -y universe
fi
sudo apt update || sudo apt update --fix-missing

echo "📦 Step 1: Setting up Flatpak and Flathub..."
if ! command -v flatpak >/dev/null 2>&1; then
    sudo apt install -y flatpak || echo "⚠️ Failed to install flatpak."
fi
if ! flatpak remotes | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi
read -p "Install Flatseal (Flatpak permissions manager)? (y/n): " flatseal_ans
if [[ "$flatseal_ans" =~ ^[Yy]$ ]]; then
    flatpak install -y flathub com.github.tchx84.Flatseal || echo "⚠️ Failed to install Flatseal."
fi

echo "🔥 Step 2: Removing Firefox Snap (if present)..."
if snap list firefox >/dev/null 2>&1; then
    sudo snap remove --purge firefox || true
    rm -rf ~/snap/firefox
    sudo rm -rf /var/snap/firefox
    sudo rm -rf /var/log/snapd.log* /var/lib/snapd/state.json.gz
    sudo killall firefox 2>/dev/null || true
    sudo snap refresh
    snap list | grep firefox || echo "✅ Firefox Snap fully removed."
else
    echo "✅ Firefox Snap not present."
fi

echo "🌐 Step 3: Brave browser setup..."
if ! command -v brave-browser >/dev/null 2>&1; then
    read -p "Install Brave Browser? (y/n): " brave_ans
    if [[ "$brave_ans" =~ ^[Yy]$ ]]; then
        curl -fsS https://dl.brave.com/install.sh | sh || echo "⚠️ Failed to install Brave."
    fi
else
    echo "✅ Brave already installed."
fi

echo "🧹 Step 4: Remove LibreOffice (APT version)?"
if dpkg -l | grep -qi libreoffice; then
    read -p "Completely remove LibreOffice and its data? (y/n): " loffice_ans
    if [[ "$loffice_ans" =~ ^[Yy]$ ]]; then
        sudo apt purge -y libreoffice* && sudo apt autoremove -y
        rm -rf ~/.config/libreoffice ~/.cache/libreoffice
        echo "✅ LibreOffice removed."
    fi
else
    echo "✅ LibreOffice not installed."
fi

echo "🎞 Step 5: Installing ubuntu-restricted-extras..."
sudo apt install -y ubuntu-restricted-extras || echo "⚠️ Failed to install ubuntu-restricted-extras."

echo "🧩 Step 6: GNOME desktop tools setup..."
if [[ "${XDG_CURRENT_DESKTOP:-}" == "GNOME" ]]; then
    read -p "Install GNOME Extension Manager and Tweaks? (y/n): " gnome_ans
    if [[ "$gnome_ans" =~ ^[Yy]$ ]]; then
        if ! flatpak list | grep -q com.mattjakeman.ExtensionManager; then
            flatpak install -y flathub com.mattjakeman.ExtensionManager || echo "⚠️ Failed to install Extension Manager."
        fi
        if ! dpkg -l | grep -qw gnome-tweaks; then
            sudo apt install -y gnome-tweaks || echo "⚠️ Failed to install GNOME Tweaks."
        fi
    fi
else
    echo "⏭ Not running GNOME. Skipping GNOME tools."
fi

echo "✅ All done."
