#!/bin/bash
# WixVM Auto-Installer - GitHub Version

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# GitHub URLs
GITHUB_REPO="wixvm/wixvm-installer"
RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/main"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

install_dependencies() {
    log_info "Installing system dependencies..."
    
    if command -v apt &> /dev/null; then
        apt update && apt install -y curl wget git python3 python3-pip python3-venv \
            nginx mysql-server certbot python3-certbot-nginx
    elif command -v yum &> /dev/null; then
        yum install -y curl wget git python3 python3-pip nginx mysql-server certbot
    fi
}

download_wixvm() {
    log_info "Downloading WixVM..."
    
    mkdir -p /opt/wixvm
    cd /opt/wixvm
    
    # Download main application
    curl -sSL "$RAW_BASE/templates/app.py" -o app.py
    curl -sSL "$RAW_BASE/templates/requirements.txt" -o requirements.txt
    
    # Create virtual environment
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
}

setup_nginx() {
    log_info "Setting up Nginx..."
    
    curl -sSL "$RAW_BASE/config/nginx.conf" -o /etc/nginx/sites-available/wixvm
    ln -sf /etc/nginx/sites-available/wixvm /etc/nginx/sites-enabled/
    systemctl restart nginx
}

show_success() {
    echo -e "${GREEN}"
    cat << "EOF"
╔══════════════════════════════════════════╗
║          WIXVM INSTALLATION COMPLETE     ║
╠══════════════════════════════════════════╣
║ 🚀 Installation successful!              ║
║                                          ║
║ Access your panel at: http://$(hostname -I | awk '{print $1}') ║
║                                          ║
║ Default credentials:                     ║
║ Username: admin                          ║
║ Password: admin123                       ║
║                                          ║
║ Next steps:                              ║
║ 1. Change default password               ║
║ 2. Configure your settings               ║
║ 3. Set up SSL certificate                ║
╚══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

main() {
    log_info "Starting WixVM installation..."
    install_dependencies
    download_wixvm
    setup_nginx
    show_success
}

main "$@"
