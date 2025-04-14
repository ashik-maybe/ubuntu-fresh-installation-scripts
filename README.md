# Ubuntu Fresh Installation Scripts

A collection of scripts to automate post-installation tasks for Ubuntu and its derivatives.

## 📂 Scripts Included

- **`install_dev_tools.sh`**: Installs developer tools like GitHub Desktop and Visual Studio Code.
- **`install_warp.sh`**: Sets up Cloudflare WARP for secure and private internet access.
- **`optimize-apt.sh`**: Optimizes `apt` for faster downloads and better performance.
- **`optimize-ubuntu-vm.sh`**: Optimizes Ubuntu for virtual machine usage.
- **`ubuntu-postinstall.sh`**: Removes Snap packages, sets up Flatpak, installs Brave Browser, and more.

## 🚀 Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ubuntu-fresh-installation-scripts.git
   cd ubuntu-fresh-installation-scripts
   ```

2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

3. Run the desired script:
   ```bash
   ./ubuntu-postinstall.sh
   ./install_dev_tools.sh
   ./install_warp.sh
   ```

## ⚠️ Prerequisites

- A fresh Ubuntu installation.
- `sudo` privileges.