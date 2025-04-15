#!/bin/bash

set -euo pipefail

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -E "^ii\s+$1\s" >/dev/null
}

echo "🔍 Checking for Cloudflare WARP..."

if is_installed "cloudflare-warp"; then
    echo "✅ Cloudflare WARP is already installed."
    exit 0
fi

read -p "⚠️ Cloudflare WARP is not installed. Do you want to install it? (y/n): " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo "❌ Installation aborted."
    exit 0
fi

echo "📦 Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl gpg

echo "🔑 Adding Cloudflare GPG key..."
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

echo "➕ Adding Cloudflare WARP repository..."
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

echo "📥 Installing Cloudflare WARP..."
sudo apt-get update
sudo apt-get install -y cloudflare-warp

echo "✅ Cloudflare WARP has been installed!"

# Post-installation guidance
cat <<EOF

🚀 Quick Guide to Using Cloudflare WARP:

🔧 Register the client:
    warp-cli registration new

🔌 Connect:
    warp-cli connect

🔎 Verify connection:
    curl https://www.cloudflare.com/cdn-cgi/trace/
    (Look for: warp=on)

⚙️ Switching modes:
    warp-cli mode doh           # DNS only
    warp-cli mode warp+doh      # Full WARP

🛡️ Families (1.1.1.1 for Families):
    warp-cli dns families off          # Disable
    warp-cli dns families malware      # Block malware
    warp-cli dns families full         # Block malware & adult content

EOF
