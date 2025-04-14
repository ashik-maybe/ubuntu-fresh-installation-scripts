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
        sudo systemctl enable --now spice-vdagentd qemu-guest-agent
        ;;
    virtualbox)
        sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
        sudo systemctl enable --now vboxservice || true
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
sudo apt install -y build-essential dkms xclip xsel

# Optionally install clipboard manager if GUI session exists
if [[ "$XDG_SESSION_TYPE" == "x11" || "$XDG_SESSION_TYPE" == "wayland" ]]; then
    sudo apt install -y clipboard-manager
fi

echo "🛠 Enabling recommended system tweaks..."

# Reduce swappiness
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf

# Enable SSD trim
sudo systemctl enable fstrim.timer

# Detect block device and set scheduler to noop
echo "⚙️ Tuning I/O scheduler..."
for dev in /sys/block/*/queue/scheduler; do
    if grep -q "noop" "$dev"; then
        echo "noop" | sudo tee "$dev" > /dev/null
    fi
done

echo "✅ VM optimization complete."
