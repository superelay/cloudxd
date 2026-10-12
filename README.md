# CloudXD Package Repository

> **Official Binary Release & One-Click Distribution Repository for CloudX**  

---

## ⚡ 1-Click Quick Installation

Run the unified one-command installer on any supported Linux host (**Ubuntu 22.04/24.04, Debian 12, Rocky Linux 9/10, AlmaLinux 9/10, RHEL 9/10**):

```bash
curl -fsSL https://raw.githubusercontent.com/superelay/cloudxd/main/install.sh | sudo bash
```

The installer will automatically:
1. Detect your distribution family (`Debian/Ubuntu` or `RHEL/Rocky/AlmaLinux`).
2. Download and verify the matching binary package.
3. Install required system virtualization dependencies (`qemu-kvm`, `libvirt`, `dnsmasq`, `nftables`, `libguestfs`).
4. Execute `/usr/lib/cloudx/cloudx-prereq --heal all` to configure bridge netfilter, storage permissions, and libvirt KVM groups.
5. Enable and start the system services (`cloudxd` and `cloudx-worker`).

---

## 📦 Manual Package Installation

If you prefer to download and install packages manually, follow the instructions for your distribution below.

### Option A: Ubuntu 22.04 / 24.04 & Debian 12 (DEB)

```bash
# 1. Download the latest Debian package
curl -fsSL -O https://raw.githubusercontent.com/superelay/cloudxd/main/cloudx_1.0.0_amd64.deb

# 2. Install dependencies and the package
sudo apt-get update
sudo apt-get install -y ./cloudx_1.0.0_amd64.deb

# 3. Heal virtualization environment prerequisites
sudo /usr/lib/cloudx/cloudx-prereq --heal all

# 4. Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now cloudxd cloudx-worker
```

---

### Option B: Rocky Linux 10 / AlmaLinux 10 / RHEL 10 (RPM)

```bash
# 1. Install EPEL repository
sudo dnf install -y epel-release

# 2. Install CloudX RPM directly
sudo dnf install -y https://raw.githubusercontent.com/superelay/cloudxd/main/cloudx-1.0.0-1.el10.x86_64.rpm

# 3. Heal virtualization environment prerequisites
sudo /usr/lib/cloudx/cloudx-prereq --heal all

# 4. Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now cloudxd cloudx-worker
```

---

### Option C: Rocky Linux 9 / AlmaLinux 9 / RHEL 9 (RPM)

```bash
# 1. Install EPEL repository
sudo dnf install -y epel-release

# 2. Install CloudX RPM directly
sudo dnf install -y https://raw.githubusercontent.com/superelay/cloudxd/main/cloudx-1.0.0-1.el9.x86_64.rpm

# 3. Heal virtualization environment prerequisites
sudo /usr/lib/cloudx/cloudx-prereq --heal all

# 4. Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now cloudxd cloudx-worker
```

---

## 🌐 Accessing CloudX Management Console

Once the installation finishes, open your web browser and navigate to:

| Service | URL / Port | Description |
| :--- | :--- | :--- |
| **CloudX Web Console** | `https://<YOUR_SERVER_IP>:3145/` | Secure HTTPS Web Management UI & noVNC Console |
| **HTTP Redirect Port** | `http://<YOUR_SERVER_IP>:3144/` | Plaintext HTTP entry point (auto-redirects to HTTPS) |

---

## 🔍 Service Status & Operations

Check the status of running CloudX services:

```bash
# View service states
sudo systemctl status cloudxd
sudo systemctl status cloudx-worker

# View live API daemon logs
sudo journalctl -u cloudxd -f

# Run virtualization health checks
sudo /usr/lib/cloudx/cloudx-prereq --check all
```

---

## 🛡️ Package Integrity (SHA-256 Checksums)

Verify downloaded packages against official checksums:

```bash
curl -fsSL https://raw.githubusercontent.com/superelay/cloudxd/main/SHA256SUMS | sha256sum --check
```

### Current Release Checksums

| Package File | Target OS / Architecture | SHA-256 Checksum |
| :--- | :--- | :--- |
| `cloudx_1.0.0_amd64.deb` | Ubuntu 22.04/24.04, Debian 12 (amd64) | `2f4e1735567f18890880a1654f60e9b05efe3f0588cad66160173d4dd54fb179` |
| `cloudx-1.0.0-1.el10.x86_64.rpm` | Rocky Linux 10, AlmaLinux 10, RHEL 10 (x86_64) | `3e2bb4e0910624586cce692ea13535700ba9308ad1c6ed22cb1fb4206964824e` |
| `cloudx-1.0.0-1.el9.x86_64.rpm` | Rocky Linux 9, AlmaLinux 9, RHEL 9 (x86_64) | `3e2bb4e0910624586cce692ea13535700ba9308ad1c6ed22cb1fb4206964824e` |

---

## 📂 Included Components

The distributed packages install the following binaries and services:

| Component | Path | Function |
| :--- | :--- | :--- |
| `cloudxd` | `/usr/lib/cloudx/cloudxd` | Core REST API daemon, scheduler, and QEMU/KVM orchestrator |
| `cloudx_worker` | `/usr/lib/cloudx/cloudx_worker` | Asynchronous worker handling disk imports, snapshots, and background jobs |
| `cloudx_live_backup`| `/usr/lib/cloudx/cloudx_live_backup` | Incremental backup engine with QEMU block dirty bitmaps |
| `cloudx-prereq` | `/usr/lib/cloudx/cloudx-prereq` | Host virtualization prerequisite validator and auto-healing engine |
| `cxs` | `/usr/lib/cloudx/cxs` | True HCI distributed storage engine and CLI |

---

## 🔗 Project Links

- **Binary Distribution Repository**: [https://github.com/superelay/cloudxd](https://github.com/superelay/cloudxd)
