#!/bin/bash

# optimize-apt.sh - Minimal script to optimize APT performance settings

set -euo pipefail

CONFIG_FILE="/etc/apt/apt.conf.d/99apt-optimized"

echo "🔧 Optimizing APT configuration..."

# Backup existing config if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    echo "⚠️ Existing APT config found at $CONFIG_FILE. Creating backup..."
    sudo cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
    echo "📦 Backup saved as ${CONFIG_FILE}.bak"
fi

# Write optimized APT config
sudo tee "$CONFIG_FILE" > /dev/null <<EOF
// Enable parallel downloads (APT 2.0+)
Acquire::Queue-Mode "access";

// Retry failed downloads
Acquire::Retries "5";

// Automatically remove unused packages when uninstalling
APT::Get::AutomaticRemove "true";

// Keep important recommended packages
APT::AutoRemove::RecommendsImportant "true";

// Show progress bars and colors
Dpkg::Progress-Fancy "1";
EOF

echo "✅ APT optimization complete."

# Option to update/upgrade
read -p "📥 Do you want to run 'sudo apt update && full-upgrade' now? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "🔄 Updating and upgrading..."
    sudo apt update && sudo apt -y full-upgrade
    echo "✅ System fully upgraded."
else
    echo "ℹ️ Skipped update/upgrade. Run manually if needed:"
    echo "    sudo apt update && sudo apt full-upgrade"
fi

echo "🎉 Done. APT is now optimized!"
