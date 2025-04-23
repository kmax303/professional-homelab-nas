# Virtual Machine Overview

This document outlines the role, configuration, and services running on the main virtual machine hosted on the physical server.

---

## 1. VM Specifications

- **OS**: Ubuntu Server (LTS)
- **Virtualization**: Hosted via KVM/QEMU on the physical server
- **Purpose**: Primary container host (Docker-based services)

---

## 2. Assigned Resources

| Resource        | Value               |
|-----------------|---------------------|
| vCPUs           | 4 cores              |
| RAM             | 6 Gb                 |
| Disk Size       | ~64 GB (OS only)     |
| Network         | Bridged interface    |

VM storage is kept minimal as data is externalized to mounted volumes or network shares.

---

## 3. Mounted Storage

| Mount Point           | Source Location                | Purpose                        |
|------------------------|-------------------------------|--------------------------------|
| `/mnt/nas_data`        | Samba share from host         | Nextcloud user data            |
| `/opt/docker/`         | Local SSD or mounted volume   | Docker services & config       |
| `/mnt/ssd1tb` (if used)| Direct passthrough or mount   | High-speed storage             |

---

## 4. Core Responsibilities

This VM hosts all Docker services split by function:

- **NAS stack**: Nextcloud, MariaDB, Redis
- **Monitoring stack**: Prometheus, Grafana, cAdvisor
- **Multimedia stack**: Jellyfin, supporting services
- **Maintenance**: Watchtower, backup scripts
- **Management**: Portainer
- **Others**: Cockpit, system tools

Each stack lives in its own directory under `/opt/docker/services/`.

---

## 5. Docker Structure

- **Base directory**: `/opt/docker/`
  - `services/` – contains all `docker-compose.yml` files
  - `volumes/` – persistent data for containers
  - `scripts/` – maintenance and utility scripts

Services are grouped for modularity and future scalability.

---

## 6. Networking

- **Internal IP**: Assigned via LAN DHCP or static lease
- **External Access**:
  - VPN tunnel (WireGuard) to VPS
  - No direct internet exposure
- **All web services** proxied via Nginx on VPS (reverse proxy)

---

## 7. Security

- No ports exposed to WAN
- Access via SSH (key-based)
- WireGuard used for remote and proxy connection
- Regular updates via unattended-upgrades or Ansible

---

## 8. Summary

The virtual machine is the central unit for all application services. It is designed for modular Docker-based deployment, secure access via VPN, and maintainability via separated stacks and backup mechanisms.