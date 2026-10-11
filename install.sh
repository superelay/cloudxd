#!/usr/bin/env bash
# ==============================================================================
# CloudX One-Click Installer
# High-Performance Linux Virtualization Control Plane & HCI Storage Engine
# ==============================================================================
# Quick Install:
#   curl -fsSL https://raw.githubusercontent.com/superelay/cloudxd/main/install.sh | sudo bash
# ==============================================================================

set -euo pipefail

# Terminal styling
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }

echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}                 CloudX 1-Click Installer                       ${NC}"
echo -e "${BOLD}   KVM Virtualization Control Plane & HCI Storage Engine        ${NC}"
echo -e "${BOLD}================================================================${NC}"

if [ "$(id -u)" -ne 0 ]; then
    log_err "This script must be run as root. Please run with sudo: sudo bash install.sh"
    exit 1
fi

GITHUB_RAW="https://raw.githubusercontent.com/superelay/cloudxd/main"
WORK_DIR=$(mktemp -d /tmp/cloudx_install_XXXXXX)
trap 'rm -rf "${WORK_DIR}"' EXIT

# 1. Detect Operating System
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_LIKE="${ID_LIKE:-}"
    OS_VER="${VERSION_ID:-}"
else
    log_err "Cannot determine operating system (/etc/os-release not found)"
    exit 1
fi

PKG_TYPE=""
INSTALL_CMD=""
PKG_NAME=""

if command -v apt-get >/dev/null 2>&1; then
    PKG_TYPE="deb"
    PKG_NAME="cloudx_1.0.0_amd64.deb"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    PKG_TYPE="rpm"
    INSTALL_CMD="$(command -v dnf || command -v yum)"
    if [[ "${OS_VER}" =~ ^10 ]]; then
        PKG_NAME="cloudx-1.0.0-1.el10.x86_64.rpm"
    else
        PKG_NAME="cloudx-1.0.0-1.el9.x86_64.rpm"
    fi
else
    log_err "Unsupported Linux distribution: neither apt-get nor dnf/yum was found."
    exit 1
fi

log_info "Detected OS: ${PRETTY_NAME:-$OS_ID} (Package format: ${PKG_TYPE})"
log_info "Target package: ${PKG_NAME}"

# 2. Locate or Download Package
LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd || echo "")"
PKG_PATH=""

if [ -n "${LOCAL_SCRIPT_DIR}" ] && [ -f "${LOCAL_SCRIPT_DIR}/${PKG_NAME}" ]; then
    log_info "Found local package file: ${LOCAL_SCRIPT_DIR}/${PKG_NAME}"
    PKG_PATH="${LOCAL_SCRIPT_DIR}/${PKG_NAME}"
else
    log_info "Downloading ${PKG_NAME} from repository..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --progress-bar "${GITHUB_RAW}/${PKG_NAME}" -o "${WORK_DIR}/${PKG_NAME}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q --show-progress "${GITHUB_RAW}/${PKG_NAME}" -O "${WORK_DIR}/${PKG_NAME}"
    else
        log_err "Neither curl nor wget is available to download the package."
        exit 1
    fi
    PKG_PATH="${WORK_DIR}/${PKG_NAME}"
fi

if [ ! -f "${PKG_PATH}" ] || [ ! -s "${PKG_PATH}" ]; then
    log_err "Failed to obtain valid package: ${PKG_NAME}"
    exit 1
fi

# 3. Install Package and Dependencies
log_info "Installing CloudX package and system dependencies..."
if [ "${PKG_TYPE}" = "deb" ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || true
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
        libvirt-daemon-system libvirt-clients qemu-kvm \
        iptables nftables dnsmasq bridge-utils \
        libguestfs-tools chntpw hivex libwin-hivex-perl \
        libpq5 libssl3 || true
    apt-get install -y "${PKG_PATH}"
elif [ "${PKG_TYPE}" = "rpm" ]; then
    $INSTALL_CMD install -y epel-release 2>/dev/null || true
    $INSTALL_CMD install -y "${PKG_PATH}"
fi

log_ok "CloudX package installed successfully."

# 4. Run Automated Environment Healing
if [ -x /usr/lib/cloudx/cloudx-prereq ]; then
    log_info "Verifying and auto-healing virtualization prerequisites..."
    /usr/lib/cloudx/cloudx-prereq --heal all || log_warn "Prerequisite check reported non-critical warnings"
fi

# 5. Enable and Start Services
log_info "Enabling and starting CloudX services..."
systemctl daemon-reload
systemctl enable cloudxd.service cloudx-worker.service
systemctl restart cloudxd.service cloudx-worker.service

sleep 2
if systemctl is-active --quiet cloudxd; then
    log_ok "CloudX API Daemon (cloudxd) is active and running."
else
    log_warn "cloudxd did not report active immediately. Check: systemctl status cloudxd"
fi

if systemctl is-active --quiet cloudx-worker; then
    log_ok "CloudX Worker (cloudx-worker) is active and running."
else
    log_warn "cloudx-worker did not report active immediately. Check: systemctl status cloudx-worker"
fi

# 6. Retrieve Primary Host IP
HOST_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || hostname -I | awk '{print $1}')
if [ -z "${HOST_IP}" ]; then
    HOST_IP="127.0.0.1"
fi

echo ""
echo -e "${GREEN}${BOLD}================================================================${NC}"
echo -e "${GREEN}${BOLD}             CloudX Installation Completed!                     ${NC}"
echo -e "${GREEN}${BOLD}================================================================${NC}"
echo -e "Web Management UI : ${BOLD}https://${HOST_IP}:3145/${NC}"
echo -e "HTTP Redirect Port : ${BOLD}http://${HOST_IP}:3144/${NC}"
echo -e "Default User       : ${BOLD}admin${NC} (or your configured master user)"
echo ""
echo -e "Service Commands:"
echo -e "  systemctl status cloudxd"
echo -e "  systemctl status cloudx-worker"
echo -e "  journalctl -u cloudxd -f"
echo -e "${GREEN}${BOLD}================================================================${NC}"
