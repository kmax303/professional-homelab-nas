# Professional Home NAS and Services Infrastructure

## Overview
This project documents the design and implementation of a self-hosted NAS and service infrastructure, intended for both home and remote access. It leverages virtualization, containerization, secure networking, and monitoring to deliver a reliable, maintainable, and scalable environment.

Designed and implemented from the ground up by an IT Architect & Analyst, the project is structured to be understandable, modular, and easy to reproduce or extend. It also serves as a strong portfolio piece for recruiters and technical teams.

## Infrastructure Summary

### 1. Physical Server (Ubuntu Server)
- Hosts virtual machines using **KVM/QEMU**.
- Provides **Samba file shares** over the local network.
- Performs **automated backups** of VMs in QCOW2 format with retention policies.

### 2. Virtual Machine (Ubuntu Server)
All services are containerized and grouped by domain using Docker Compose. Directory: `/opt/docker/`

#### Docker Modules:
- **nas**
  - Nextcloud
  - MariaDB
  - Redis
- **monitoring**
  - Prometheus
  - Grafana
  - cAdvisor
- **multimedia**
  - Jellyfin
- **portainer**
  - Portainer CE
- **maintenance**
  - Watchtower
  - Scheduled backups/scripts

Shared data (e.g., from physical host) is mounted under `/mnt/` (e.g., `/mnt/nas_data`, `/mnt/multimedia`, `/mnt/backup`).

### 3. VPS (Ubuntu Server)
Acts as a secure gateway and proxy to expose services to the internet.
- **Nginx reverse proxy** with HTTPS (Let's Encrypt)
- **Fail2Ban** for brute-force protection
- **WireGuard VPN** to connect the VPS with the home infrastructure

All remote access is routed through the VPN tunnel, and only essential ports are exposed (e.g., 443).

## Project Structure
```
/opt/docker/
├── services/
│   ├── nas/
│   ├── monitoring/
│   ├── multimedia/
│   ├── portainer/
│   └── maintenance/
├── volumes/        # Persistent Docker volumes
└── scripts/        # Backup, update, and utility scripts
```

## Documentation Layout
- `README.md` (this file): General project architecture and overview
- `docs/` (directory with sub-docs):
  - `physical-server.md`
  - `virtual-machine.md`
  - `vps.md`
  - `networking.md`
  - `security.md`
  - `docker-structure.md`
  - `backup-strategy.md`
- `diagrams/`: Network, Docker, and architecture diagrams

## Goals and Highlights
- **Professional architecture** with clean separation of concerns
- **Modular Docker design** with clear volume and config management
- **Secure remote access** via VPN and reverse proxy
- **Full monitoring and logging stack**
- **Scalable and reproducible setup**, ready for public GitHub presentation or recruitment

---

> Designed with a long-term goal in mind: to be robust, transparent, and impressive for both production and technical interviews.

