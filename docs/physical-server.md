# Physical Server Overview

This document describes the role, configuration, and responsibilities of the physical server in the homelab infrastructure.

---

## 1. Host System

- **OS**: Ubuntu Server LTS
- **Purpose**:
  - Virtualization host (KVM/QEMU)
  - Local file server (Samba)
  - Backup orchestrator (VM snapshots)

---

## 2. Hardware Resources

| Component      | Specification          |
|----------------|------------------------|
| CPU            | 12 cores                |
| RAM            | 16 GB                  |
| System Disk    | 500 GB (OS)            |
| SSD (USB)      | 1 TB (High-speed data) |
| SSD (Internal) | 2 TB (NAS data)        |

---

## 3. Virtualization Layer

- **Technology**: KVM/QEMU with `libvirt`
- **Managed VM**:
  - OS: Ubuntu Server (LTS)
  - Role: Main Docker host
- **Management Tools**:
  - `virsh`, `virt-manager`
- **Backup Strategy**:
  - Graceful shutdown before snapshot
  - `qemu-img` used for incremental QCOW2 snapshots
  - VM XML configs backed up for disaster recovery

---

## 4. Storage Configuration

| Mount Point     | Purpose                       |
|-----------------|-------------------------------|
| `/mnt/ssd1tb`   | Docker volumes / fast storage |
| `/mnt/hdd2tb`   | NAS data / Samba share        |
| `/mnt/backups`  | VM snapshots / XML backups    |

- Mounts defined in `/etc/fstab` using UUIDs
- All paths exposed as volumes or Samba shares

---

## 5. Samba File Sharing

- **Scope**: LAN-only access
- **Shared Paths**:
  - `/mnt/hdd2tb/nas_data`
- **Usage**: VM mounts this share as persistent Nextcloud storage

---

## 6. Network & Security

- **VPN Access**:
  - WireGuard-based remote access
- **Firewall**:
  - `ufw` configured to allow only necessary ports

---

## 7. Summary

The physical server is the foundation of the homelab. It provides computing resources, virtualization capabilities, shared storage, and backup services — all essential for stable and secure operation of the virtual machine and hosted containers.