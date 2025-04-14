#!/bin/bash
# ubuntu-postinstall.sh — Post-install setup for Ubuntu & derivatives

set -euo pipefail
sudo -v

echo "🚀 Starting Ubuntu post-install tasks..."
echo "💡 Tip: For faster downloads, switch to a local mirror via 'Software & Updates' ➜ 'Download from'."
read -p "Have you already done that? (y/n): " _

# Step 0: Enable Universe repo and update
echo "📦 Ensuring 'universe' repo is enabled..."
sudo add-apt-repository -y universe
sudo apt update

# Step 1: Flatpak + Flathub setup
echo "📦 Installing Flatpak and adding Flathub..."
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
read -p "Install Flatseal (Flatpak permission manager)? (y/n): " flatseal_ans
if [[ "$flatseal_ans" =~ ^[Yy]$ ]]; then
    flatpak install -y flathub com.github.tchx84.Flatseal || echo "⚠️ Failed to install Flatseal"
fi

# Step 2: Remove Firefox Snap
if snap list | grep -q "^firefox"; then
    echo "🧹 Removing Firefox Snap and its data..."
    sudo snap remove --purge firefox || true
    rm -rf ~/snap/firefox
    sudo rm -rf /var/snap/firefox
    sudo rm -rf /var/log/snapd.log* /var/lib/snapd/state.json.gz
    sudo killall firefox 2>/dev/null || true
    echo "✅ Firefox Snap removed."
else
    echo "⚠️ Firefox Snap not installed. Skipping removal."
fi

# Step 3: Brave browser (optional)
if ! command -v brave-browser &>/dev/null; then
    read -p "Install Brave Browser? (y/n): " brave_ans
    if [[ "$brave_ans" =~ ^[Yy]$ ]]; then
        echo "🌐 Installing Brave Browser..."
        curl -fsS https://dl.brave.com/install.sh | sh || echo "⚠️ Brave installation failed"
    fi
else
    echo "✅ Brave Browser is already installed."
fi

# Step 4: Optional removals
read -p "Remove LibreOffice completely? (y/n): " libre_ans
if [[ "$libre_ans" =~ ^[Yy]$ ]]; then
    echo "🧹 Removing LibreOffice..."
    sudo apt purge -y libreoffice*
    sudo apt autoremove -y
    rm -rf ~/.config/libreoffice ~/.cache/libreoffice
    echo "✅ LibreOffice removed."
fi

# Step 4: Ask and remove Thunderbird Snap and data
if snap list | grep -q "^thunderbird"; then
    read -rp "❓ Do you want to completely remove Thunderbird and its data? (y/n): " remove_thunderbird
    if [[ "$remove_thunderbird" =~ ^[Yy]$ ]]; then
        echo "🧹 Removing Thunderbird Snap and its data..."
        sudo snap remove --purge thunderbird || true
        rm -rf ~/snap/thunderbird
        sudo rm -rf /var/snap/thunderbird
        sudo rm -rf /var/log/snapd.log* /var/lib/snapd/state.json.gz
        sudo killall thunderbird 2>/dev/null || true
        # Remove any leftover user config/cache/data
        rm -rf ~/.thunderbird ~/.mozilla-thunderbird ~/.cache/thunderbird ~/.local/share/thunderbird
        echo "✅ Thunderbird completely removed."
    else
        echo "⏭️ Skipping Thunderbird removal."
    fi
else
    echo "⚠️ Thunderbird Snap not installed. Skipping removal."
fi


# Step 5: Restricted extras
echo "🎵 Installing Ubuntu restricted extras..."
sudo apt install -y ubuntu-restricted-extras || echo "⚠️ Failed to install restricted extras"

# Step 6: GNOME-specific tools
if [ "$(echo $XDG_CURRENT_DESKTOP | grep -i gnome)" ]; then
    read -p "Install GNOME Tweaks & Extension Manager? (y/n): " gnome_ans
    if [[ "$gnome_ans" =~ ^[Yy]$ ]]; then
        flatpak install -y flathub com.mattjakeman.ExtensionManager || echo "⚠️ Failed to install Extension Manager"
        sudo apt install -y gnome-tweaks || echo "⚠️ Failed to install GNOME Tweaks"
        echo "✅ GNOME tools installed."
    fi
fi

echo "🎉 All done! Your system is now ready."
