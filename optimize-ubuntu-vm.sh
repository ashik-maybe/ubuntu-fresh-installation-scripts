#!/bin/bash
# optimize-ubuntu-vm.sh — Optimize Ubuntu VM after installation

set -euo pipefail
sudo -v

echo "🧠 Detecting virtual machine environment..."

vm_type=$(systemd-detect-virt)
if [[ "$vm_type" == "none" ]]; then
    echo "❌ Not running inside a VM. Exiting."
    exit 1
fi

echo "✅ VM detected: $vm_type"

echo "🔧 Installing VM guest utilities..."

case "$vm_type" in
    kvm|qemu)
        sudo apt install -y spice-vdagent qemu-guest-agent
        sudo systemctl enable spice-vdagentd --now
        sudo systemctl enable qemu-guest-agent --now
        ;;
    virtualbox)
        sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
        sudo systemctl enable vboxservice --now || true
        ;;
    vmware)
        sudo apt install -y open-vm-tools open-vm-tools-desktop
        ;;
    microsoft)
        sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual
        ;;
    *)
        echo "⚠️ No specific optimization available for VM type: $vm_type"
        ;;
esac

echo "📦 Installing useful tools..."
sudo apt install -y build-essential dkms clipboard-manager xclip xsel

# Optional tweaks
echo "🛠 Enabling recommended system tweaks..."

# Reduce swappiness
sudo sysctl vm.swappiness=10
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null

# Enable trim for SSD-backed storage (often used in VMs)
sudo systemctl enable fstrim.timer

# Improve I/O performance
echo "noop" | sudo tee /sys/block/sda/queue/scheduler 2>/dev/null || true

echo "✅ VM optimization complete."
