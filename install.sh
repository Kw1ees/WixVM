#!/bin/bash
# WixVM One-Command Installer
# Official installation script: curl -sSL https://wixvm.dev/install | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
INSTALL_URL="https://raw.githubusercontent.com/wixvm/installer/main/auto_install.sh"
TMP_INSTALLER="/tmp/wixvm_installer.sh"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        log_info "Please run: sudo bash -c \"\$(curl -sSL https://wixvm.dev/install)\""
        exit 1
    fi
}

# Check internet connection
check_internet() {
    if ! curl -Is https://github.com > /dev/null 2>&1; then
        log_error "No internet connection detected"
        exit 1
    fi
}

# Download and execute installer
download_installer() {
    log_info "Downloading WixVM installer..."
    
    if curl -sSL "$INSTALL_URL" -o "$TMP_INSTALLER"; then
        chmod +x "$TMP_INSTALLER"
        log_success "Installer downloaded successfully"
    else
        log_error "Failed to download installer"
        exit 1
    fi
}

# Main execution
main() {
    echo -e "${GREEN}"
    cat << "EOF"
__      __ _  __  __ _  __  __ 
\ \    / /| |/ / |  \ \/ / |  \
 \ \/\/ / |   /  | | |\  /  | | 
  \_/\_/  |_|\_\ |_| | \/   |_| 
EOF
    echo -e "${NC}"
    echo "WixVM Automated Installation"
    echo "============================="
    
    check_root
    check_internet
    download_installer
    
    log_info "Starting installation..."
    bash "$TMP_INSTALLER" "$@"
    
    # Cleanup
    rm -f "$TMP_INSTALLER"
}

# Handle interrupts
trap 'log_error "Installation interrupted"; exit 1' INT TERM

main "$@"
