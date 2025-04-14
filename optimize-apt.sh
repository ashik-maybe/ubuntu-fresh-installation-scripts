#!/bin/bash

# optimize-apt.sh - Minimal script to optimize APT performance settings

set -e  # Exit on error

echo "🔧 Optimizing APT configuration..."

# 1. Create optimized APT config
sudo tee /etc/apt/apt.conf.d/99apt-optimized > /dev/null <<EOF
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

# 2. Reload and optionally upgrade (optional step, user can skip)
read -p "Do you want to run 'sudo apt update' and 'full-upgrade' now? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "📦 Updating package lists and upgrading..."
    sudo apt update && sudo apt -y full-upgrade
    echo "✅ System upgraded."
else
    echo "ℹ️ Skipped update/upgrade. You can run it later with:"
    echo "    sudo apt update && sudo apt full-upgrade"
fi

echo "🎉 Done. APT is now optimized."

