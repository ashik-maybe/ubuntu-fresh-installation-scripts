#!/bin/bash

set -euo pipefail

is_installed() {
    command -v "$1" &>/dev/null
}

echo "🔍 Checking for Cloudflare WARP..."

if is_installed "warp-cli"; then
    echo "✅ Cloudflare WARP is already installed."
    exit 0
fi

echo "📦 Installing Cloudflare WARP..."

sudo apt-get update
sudo apt-get install -y curl gpg lsb-release

curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

sudo apt-get update
sudo apt-get install -y cloudflare-warp

echo "✅ Cloudflare WARP installed."
