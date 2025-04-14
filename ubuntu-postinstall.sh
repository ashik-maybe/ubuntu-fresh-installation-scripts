#!/bin/bash
# ubuntu-postinstall.sh — Post-install setup for Ubuntu & derivatives

set -euo pipefail
sudo -v

echo "🚀 Starting Ubuntu post-install tasks..."
echo "💡 Tip: For faster downloads, switch to a local mirror via 'Software & Updates' ➜ 'Download from'."
read -p "Have you already done that? (y/n): " _

# Step 0: Enable Universe repo and update
echo "📦 Ensuring 'universe' repo is enabled..."
if ! grep -q "^deb .* universe" /etc/apt/sources.list; then
    sudo add-apt-repository -y universe || echo "⚠️ Failed to enable Universe repository."
else
    echo "✅ Universe repository already enabled."
fi
sudo apt update

# Step 1: Handle Snap-based Firefox/Thunderbird removal
if command -v snap >/dev/null 2>&1; then
    echo "🔍 Snap is installed. Checking for Firefox and Thunderbird..."

    # Force remove Firefox Snap if present
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

    # Force remove Thunderbird Snap if present
    if snap list | grep -q "^thunderbird"; then
        echo "🧹 Removing Thunderbird Snap and its data..."
        sudo snap remove --purge thunderbird || true
        rm -rf ~/snap/thunderbird
        sudo rm -rf /var/snap/thunderbird
        sudo rm -rf /var/log/snapd.log* /var/lib/snapd/state.json.gz
        sudo killall thunderbird 2>/dev/null || true
        # Remove leftover user config/cache/data
        rm -rf ~/.thunderbird ~/.mozilla-thunderbird ~/.cache/thunderbird ~/.local/share/thunderbird
        echo "✅ Thunderbird completely removed."
    else
        echo "⚠️ Thunderbird Snap not installed. Skipping removal."
    fi
else
    echo "⚠️ Snap is not installed. Skipping Snap-related removals."
fi

# Step 2: Remove LibreOffice if requested
if dpkg -l | grep -q "libreoffice"; then
    read -p "Remove LibreOffice completely? (y/n): " libre_ans
    if [[ "$libre_ans" =~ ^[Yy]$ ]]; then
        echo "🧹 Removing LibreOffice..."
        sudo apt purge -y libreoffice*
        sudo apt autoremove -y
        rm -rf ~/.config/libreoffice ~/.cache/libreoffice
        echo "✅ LibreOffice removed."
    else
        echo "⏭️ Skipping LibreOffice removal."
    fi
else
    echo "⚠️ LibreOffice not installed. Skipping removal."
fi

# Step 3: Install Flatpak + Flathub setup
echo "📦 Installing Flatpak and adding Flathub..."
if ! command -v flatpak >/dev/null 2>&1; then
    sudo apt install -y flatpak || echo "⚠️ Failed to install Flatpak"
else
    echo "✅ Flatpak already installed."
fi

if ! flatpak remotes | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || echo "⚠️ Failed to add Flathub"
else
    echo "✅ Flathub already configured."
fi

# Check if Flatseal is installed
if flatpak list | grep -q com.github.tchx84.Flatseal; then
    echo "✅ Flatseal is already installed."
else
    read -p "Install Flatseal (Flatpak permission manager)? (y/n): " flatseal_ans
    if [[ "$flatseal_ans" =~ ^[Yy]$ ]]; then
        flatpak install -y flathub com.github.tchx84.Flatseal || echo "⚠️ Failed to install Flatseal"
    else
        echo "⏩ Skipping Flatseal installation."
    fi
fi

# Step 4: Install Brave Browser if not present
if ! command -v brave-browser &>/dev/null; then
    if ! command -v curl &>/dev/null; then
        echo "📦 Installing curl..."
        sudo apt update
        sudo apt install -y curl || echo "⚠️ Failed to install curl"
    fi

    echo "🌐 Brave Browser not found. Installing..."
    curl -fsS https://dl.brave.com/install.sh | sh || echo "⚠️ Failed to install Brave Browser"
else
    echo "✅ Brave Browser is already installed."
fi

# Step 5: Restricted extras
if dpkg -l | grep -q "ubuntu-restricted-extras"; then
    echo "✅ Ubuntu restricted extras already installed."
else
    echo "🎵 Installing Ubuntu restricted extras..."
    sudo apt install -y ubuntu-restricted-extras || echo "⚠️ Failed to install restricted extras"
fi

# Step 6: GNOME-specific tools
if [[ "${XDG_CURRENT_DESKTOP,,}" == *gnome* ]]; then
    echo "🔍 GNOME detected. Checking for GNOME-specific tools..."

    if dpkg -l | grep -q "^ii\s\+gnome-tweaks" || command -v gnome-tweaks >/dev/null 2>&1; then
        echo "✅ GNOME Tweaks is already installed."
    else
        read -p "Install GNOME Tweaks? (y/n): " tweaks_ans
        if [[ "$tweaks_ans" =~ ^[Yy]$ ]]; then
            echo "📦 Installing GNOME Tweaks..."
            sudo apt install -y gnome-tweaks || echo "⚠️ Failed to install GNOME Tweaks"
        else
            echo "⏭️ Skipping GNOME Tweaks installation."
        fi
    fi

    if flatpak list | grep -q "com.mattjakeman.ExtensionManager"; then
        echo "✅ Extension Manager is already installed."
    else
        read -p "Install Extension Manager? (y/n): " ext_manager_ans
        if [[ "$ext_manager_ans" =~ ^[Yy]$ ]]; then
            flatpak install -y flathub com.mattjakeman.ExtensionManager || echo "⚠️ Failed to install Extension Manager"
        else
            echo "⏭️ Skipping Extension Manager installation."
        fi
    fi
else
    echo "⚠️ Not running GNOME. Skipping GNOME-specific tools."
fi

# Final Step: System upgrade
echo "📦 Upgrading system packages..."
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
echo "✅ System upgrade complete."

echo "🎉 All done! Your system is now ready."
