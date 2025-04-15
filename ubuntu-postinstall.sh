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

# ─── Initial Checks and Prompts ────────────────────────────────

ask_install() {
    local name="$1"
    local check_cmd="$2"
    local varname="$3"

    if eval "$check_cmd" >/dev/null 2>&1; then
        eval "$varname=false"
        echo "✅ $name is already installed."
    else
        read -p "Install $name? (y/n): " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            eval "$varname=true"
        else
            eval "$varname=false"
        fi
    fi
}

ask_install "Brave Browser" "command -v brave-browser" brave_ans
ask_install "Flatseal" "flatpak list | grep -q com.github.tchx84.Flatseal" flatseal_ans

# GNOME tools: only if current desktop is GNOME
if [[ "${XDG_CURRENT_DESKTOP,,}" == *gnome* ]]; then
    ask_install "GNOME Tweaks" "command -v gnome-tweaks" tweaks_ans
    ask_install "Extension Manager" "flatpak list | grep -q com.mattjakeman.ExtensionManager" extman_ans
else
    tweaks_ans=false
    extman_ans=false
    echo "⚠️ GNOME not detected. Skipping GNOME Tweaks and Extension Manager."
fi

# ─── Step 1: Snap cleanup (Firefox + Thunderbird) ──────────────

if command -v snap >/dev/null 2>&1; then
    echo "🔍 Snap is installed. Checking for Firefox and Thunderbird..."

    if snap list | grep -q "^firefox"; then
        echo "🧹 Removing Firefox Snap and its data..."
        sudo snap remove --purge firefox || true
        rm -rf ~/snap/firefox
        sudo rm -rf /var/snap/firefox /var/log/snapd.log* /var/lib/snapd/state.json.gz
        sudo killall firefox 2>/dev/null || true
        echo "✅ Firefox Snap removed."
    else
        echo "⚠️ Firefox Snap not installed. Skipping."
    fi

    if snap list | grep -q "^thunderbird"; then
        echo "🧹 Removing Thunderbird Snap and its data..."
        sudo snap remove --purge thunderbird || true
        rm -rf ~/snap/thunderbird
        sudo rm -rf /var/snap/thunderbird /var/log/snapd.log* /var/lib/snapd/state.json.gz
        sudo killall thunderbird 2>/dev/null || true
        rm -rf ~/.thunderbird ~/.mozilla-thunderbird ~/.cache/thunderbird ~/.local/share/thunderbird
        echo "✅ Thunderbird Snap removed."
    else
        echo "⚠️ Thunderbird Snap not installed. Skipping."
    fi
else
    echo "⚠️ Snap is not installed. Skipping Snap-related removals."
fi

# ─── Step 2: Flatpak + Flathub setup ──────────────────────────

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

# ─── Step 3: System upgrade ───────────────────────────────────

echo "📦 Upgrading system packages..."
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
echo "✅ System upgrade complete."

# ─── Step 4: Remove LibreOffice ───────────────────────────────

if dpkg -l | grep -E '^ii\s+libreoffice'; then
    echo "🧹 LibreOffice detected. Removing all LibreOffice components..."
    sudo apt purge -y $(dpkg --get-selections | grep -E '^libreoffice' | awk '{print $1}')
    sudo apt autoremove -y
    rm -rf ~/.config/libreoffice ~/.cache/libreoffice ~/.local/share/libreoffice
    echo "✅ LibreOffice removed."
else
    echo "⚠️ LibreOffice not installed. Skipping."
fi

# ─── Step 5: Remove GIMP ───────────────────────────────────────

if dpkg -l | grep -E '^ii\s+gimp'; then
    echo "🧹 GIMP detected. Removing..."
    sudo apt purge -y gimp gimp-data gimp-plugin-registry gimp-data-extras
    sudo apt autoremove -y
    rm -rf ~/.config/GIMP ~/.cache/gimp ~/.gimp*
    echo "✅ GIMP removed."
else
    echo "⚠️ GIMP not installed. Skipping."
fi

# ─── Step 6: Install Brave ─────────────────────────────────────

if [ "$brave_ans" = true ]; then
    echo "🌐 Installing Brave Browser..."
    if ! command -v curl &>/dev/null; then
        sudo apt install -y curl
    fi
    curl -fsS https://dl.brave.com/install.sh | sh || echo "⚠️ Failed to install Brave Browser"
fi

# ─── Step 7: Optional installs ─────────────────────────────────

if [ "$flatseal_ans" = true ]; then
    flatpak install -y flathub com.github.tchx84.Flatseal || echo "⚠️ Failed to install Flatseal"
fi

if [ "$tweaks_ans" = true ]; then
    sudo apt install -y gnome-tweaks || echo "⚠️ Failed to install GNOME Tweaks"
fi

if [ "$extman_ans" = true ]; then
    flatpak install -y flathub com.mattjakeman.ExtensionManager || echo "⚠️ Failed to install Extension Manager"
fi

# ─── Step 8: Install restricted extras (no check) ─────────────

echo "📦 Installing Ubuntu restricted extras..."
sudo apt install -y ubuntu-restricted-extras || echo "⚠️ Failed to install restricted extras"
echo "✅ Ubuntu restricted extras installed."

echo "🎉 All done! Your system is now clean, sharp, and ready to go!"
