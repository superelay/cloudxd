# CloudX Platform — Release Candidate 1 (`v1.0.0-rc1`)
### Experimental / Release Candidate Feature Specification & Release Notes

> **Version:** `1.0.0-rc1` (Experimental / Release Candidate)  
> **Release Date:** October 14, 2026  
> **Target Architecture:** `x86_64` (AMD64)  
> **Supported Host Distributions:**  
> - Ubuntu 22.04 LTS (Jammy), Ubuntu 24.04 LTS (Noble), Ubuntu 26.04 LTS  
> - Debian 12 (Bookworm)  
> - Rocky Linux 9 / 10  
> - AlmaLinux 9 / 10  
> - Red Hat Enterprise Linux 9 / 10  

---

## Executive Summary

**CloudX** is an enterprise-grade, high-performance, hyperconverged infrastructure (HCI) control plane and virtualization orchestration platform. Built on an ultra-low latency, multi-threaded C core (`cloudxd`, `cloudx_worker`) and a modern web management console, CloudX combines KVM/QEMU hypervisor orchestration, True HCI distributed storage (CXS), software-defined networking, autonomous guest self-healing (`rescue-agent`), and cross-platform workload migration into a unified, zero-lock-in platform.

This **v1.0.0-rc1** (Release Candidate 1) represents the complete, feature-frozen implementation of the CloudX virtualization platform, incorporating experimental subsystems for evaluation and production hardening.

---

## 1. Compute & Virtual Machine Orchestration

### 1.1 Hypervisor Core (KVM / QEMU / Libvirt)
- **High-Throughput Asynchronous Core**: Asynchronous event-driven daemon (`cloudxd`) capable of servicing high-concurrency REST API requests and scheduling VM provisioning jobs.
- **Complete Guest Lifecycle Management**: Zero-latency Provisioning, Start, ACPI Graceful Shutdown, Hard Poweroff, Pause, Resume, Reset, Snapshot, Clone, and Termination.
- **Granular vCPU Topology**: Full configuration of Sockets, Cores, and Threads, with support for live resource adjustments, CPU pinning, NUMA node binding, hugepages, and vCPU shares/quotas.
- **Virtualization & CPU Models**: Support for `host-passthrough`, `host-model`, and custom CPU configurations.
- **Nested Virtualization**: First-class toggle (`enable_nested_virt`) for hosting nested KVM instances, testing environments, or containerized hypervisors within guest VMs.
- **Firmware Support**: Full support for both legacy `SeaBIOS` and modern `OVMF UEFI` firmware (including Secure Boot support).
- **PCIe & GPU Passthrough (VFIO)**: Direct hardware assignment of physical PCIe devices and enterprise GPUs (NVIDIA/AMD) directly to guest instances.
- **Dynamic Resource Autoscaling**: Autonomous workload monitoring with configurable scaling thresholds for CPU, memory, and disk usage with anti-flapping cooldown windows.

---

## 2. Autonomous Guest Customization & Micro-Injector

### 2.1 Strategy A Micro-Kernel Fast-Injector (`cloudx-injector`)
- **Sub-Second Runtime Injection**: Lightweight micro-kernel injection engine that operates directly against guest storage partitions offline, bypassing slow seed ISO / config-drive mounts.
- **Dynamic Binary Resolution**: Automatically detects host and guest utilities (`busybox`, `chntpw`, `hivex`) to inject network configurations, authorized SSH keys, user accounts, and startup scripts.

### 2.2 Multi-Distro Linux Offline Customization
- **Universal OS Inspection**: Native offline filesystem inspection and modification for Debian, Ubuntu, CentOS, RHEL, Rocky Linux, AlmaLinux, Fedora, openSUSE, Alpine, and Arch Linux.
- **Automated Partition & Filesystem Expansion**: Automatically expands GPT/MBR partition tables and grows root filesystems (`ext4`, `xfs`, `btrfs`) to fill the provisioned disk volume without guest reboots.
- **Cloud-Init Engine**: Seamless generation of NoCloud and Config-Drive ISO metadata as an automated fallback mechanism.

### 2.3 Windows Offline Injection Engine
- **Administrator Password Injection**: Offline credential injection with full support for special characters (exclamation marks, symbols) via delayed variable expansion isolation.
- **Automated Hostname Renaming**: NetBIOS and DNS computer name configuration applied offline via registry modifications and post-boot PowerShell directives (`Rename-Computer`).
- **Remote Desktop Protocol (RDP)**: Automatic enablement of `TermService`, startup type configuration (`auto`), security layer configuration, and Windows Firewall port 3389 rules.
- **Automated Session Cleanup**: Detached timeout cleanup scripts and forced logoff / restart handlers for newly provisioned Windows instances.

---

## 3. Autonomous Rescue & Self-Healing Agent Subsystem (`rescue-agent`)

The `rescue-agent` is an autonomous diagnostic and recovery subsystem designed to detect, analyze, and repair broken or unbootable virtual machines:

- **Root & OS Detection**: Automatically scans raw block devices, QCOW2 images, and LVM volumes to detect root partitions and operating system versions.
- **Filesystem Integrity Healing**: Runs non-destructive filesystem consistency checks (`fsck`, journal playback) on corrupted volumes.
- **fstab Re-Alignment**: Automatically resolves UUID mismatches in `/etc/fstab` caused by disk migrations, disk cloning, or volume replacements.
- **LVM Recovery**: Activates corrupted volume groups, reconstructs thin pools, and restores corrupted LVM metadata headers.
- **Bootloader Repair**: Automated reinstallation and configuration of Grub2 and EFI NVRAM entries on unbootable Linux instances.
- **initramfs Reconstruction**: Dynamically rebuilds `initramfs` / `initrd` images when storage drivers or disk buses change (e.g., migrating from IDE to VirtIO-SCSI).
- **Space Recovery**: Intelligent cleanup of rotated logs, caches, and orphan core dumps on disks filled to 100% capacity to allow instances to successfully boot.
- **Extensible Lifecycle Hooks**: Pre- and post-execution hook framework (`vm-start`, `vm-wait-healthy`, `vm-is-stopped`, `attach`, `detach`, `snapshot`, `rollback`).

---

## 4. Cross-Hypervisor Live Import Engine

- **Agentless Migration Pipeline**: Native, streaming migration directly from VMware ESXi hypervisors and Proxmox VE clusters over secure SSH tunnels.
- **Broad Image Format Ingestion**: Direct ingestion of `VMDK` (thick, thin, monolithic, twoGbMaxExtentSplit), `QCOW2`, `RAW`, `VHDX`, and `OVA`/`OVF` appliance packages.
- **Real-Time Telemetry Streaming**: Live streaming progress tracker reporting instantaneous transfer bandwidth (MB/s), total GiB transferred, and dynamic ETA calculation.
- **Non-Destructive Ephemeral Snapshots**: Creates and locks temporary snapshots on source hypervisors to prevent downtime or source data corruption during transfer.
- **Automatic Metadata & Driver Translation**: Translates source virtual hardware definitions (vCPUs, RAM, networks, MAC addresses) into native CloudX specifications.

---

## 5. True HCI Distributed Storage (CXS) & Object Store

### 5.1 Pluggable Storage Backends
- **CXS Distributed Datastores**: High-performance clustered storage mesh using Raft distributed consensus for metadata and synchronous block replication.
- **LVM & LVM ThinPool**: Fast raw block device storage with thin provisioning, overcommit, and snapshot support.
- **ZFS (ZPool / ZVol)**: Copy-on-write sparse datasets with instantaneous snapshotting and checksum verification.
- **Ceph RBD**: Enterprise scale-out distributed block storage integration.
- **NFS Datastores**: Shared network filesystem datastores with automated mount monitoring and failover.

### 5.2 Dynamic Volume Lifecycle
- **Live Disk Hotplug**: Attach and detach secondary virtual disks to running VMs without interruption.
- **Dynamic Resizing**: Online and offline virtual disk growth with automatic DB registration.
- **Multi-Bus Emulation**: Support for `virtio-blk`, `virtio-scsi`, `sata`, and `ide` controllers.

### 5.3 CXS S3-Compatible Object Store
- **Native S3 REST API**: Full bucket and object lifecycle management.
- **Presigned URLs**: Secure presigned object access with configurable expiration timeouts (15m, 1h, 24h, custom).
- **High-Throughput Streaming**: Multi-part upload and binary streaming support for large disk images, ISOs, and database backups.

---

## 6. Software-Defined Networking & Security Microsegmentation

- **Virtual Switching**: Support for Linux Software Bridges (`cxbr0`, `virbr0`), Open vSwitch (OVS), and dynamic VXLAN mesh overlays.
- **Stateful Network Firewalls**: Distributed firewall engine using `nftables` and `iptables-nft` with stateful connection tracking (`conntrack`).
- **Granular Security Groups**: Dynamic evaluation of ingress and egress rules across CIDRs, protocols (TCP, UDP, ICMP), and port ranges.
- **Strict Anti-Spoofing Filters**: MAC-IP binding filters on virtual tap devices preventing IP spoofing and rogue ARP poisoning.
- **Automated IPAM**: Subnet management with automated IPv4/IPv6 allocation, gateway assignment, and lease recycling.
- **Floating Elastic IPs**: 1:1 NAT mapping for external ingress routing to internal guest instances.

---

## 7. High Availability & Distributed Clustering

- **Consensus-Driven Clustering**: Multi-node control plane with Raft leader election, autonomous node discovery, and health heartbeats.
- **Split-Brain Mitigation**: Adaptive heartbeat daemon with network link-flap mitigation and quorum enforcement.
- **Autonomous Workload Evacuation**: Automatic failover and restart of guest workloads on surviving hypervisor nodes during host failure.
- **Live Telemetry & Metrics**: Native Prometheus `/metrics` endpoint exporting live guest statistics, host saturation, and queue metrics.
- **Tamper-Evident Audit Trail**: Cryptographic logging capturing all management events, actors, tenant IDs, timestamps, and resource mutations.

---

## 8. Security, Multi-Tenancy & Safety Guardrails

- **3-Tier RBAC Architecture**: Platform Administrators (full control), Tenant Administrators (tenant isolation), and Project Users (restricted compute access).
- **Authentication**: Local database authentication with salted SHA-512 hashes, enterprise LDAP / Active Directory sync, and TOTP Two-Factor Authentication.
- **Data Protection**: AES-256-CBC encryption-at-rest for guest passwords, secrets, and private keys.
- **Destructive Action Safety Verification**: Two-step confirmation with randomized verification challenge phrases before executing high-risk operations (e.g. VM deletion, disk formatting, force poweroff).
- **HTML5 Web Console**: In-browser interactive console via integrated QEMU VNC server and WebSockify token proxy with single-use authentication tokens.

---

## 9. Distribution Packages & Checksums (`v1.0.0-rc1`)

Official release candidate binaries are packaged and verified under the following checksums:

| Package File | Target OS / Architecture | SHA-256 Checksum |
| :--- | :--- | :--- |
| `cloudx_1.0.0_amd64.deb` | Ubuntu 22.04/24.04/26.04, Debian 12 (amd64) | `e1387785e83c18b255712b59251d980383e64b46ef9da676fcc3264e871f274c` |
| `cloudx-1.0.0-1.el10.x86_64.rpm` | Rocky Linux 10, AlmaLinux 10, RHEL 10 (x86_64) | `dffb15f7e6308b47ff923df80cbd05f933985fd053a8b492ca695b8c1fb589c3` |
| `cloudx-1.0.0-1.el9.x86_64.rpm` | Rocky Linux 9, AlmaLinux 9, RHEL 9 (x86_64) | `dffb15f7e6308b47ff923df80cbd05f933985fd053a8b492ca695b8c1fb589c3` |

---

## 10. Quick Installation Guide

### Automated 1-Click Installation
```bash
curl -fsSL https://raw.githubusercontent.com/superelay/cloudxd/main/install.sh | sudo bash
```

### Manual Debian / Ubuntu Installation
```bash
sudo apt-get update
sudo apt-get install -y ./cloudx_1.0.0_amd64.deb
sudo /usr/lib/cloudx/cloudx-prereq --heal all
sudo systemctl daemon-reload
sudo systemctl enable --now cloudxd cloudx-worker
```

### Manual Rocky Linux / RHEL Installation
```bash
sudo dnf install -y epel-release
sudo dnf install -y ./cloudx-1.0.0-1.el10.x86_64.rpm
sudo /usr/lib/cloudx/cloudx-prereq --heal all
sudo systemctl daemon-reload
sudo systemctl enable --now cloudxd cloudx-worker
```
