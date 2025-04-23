# Docker Architecture and Structure

This document describes the containerized architecture, modular service structure, and Docker management practices used within the virtual machine.

---

## 1. Overview

All services run in Docker containers on the **Ubuntu Server Virtual Machine**. Containers are grouped by function and managed via separate Docker Compose files to ensure modularity, easier maintenance, and clearer separation of concerns.

---

## 2. Directory Structure

/opt/docker/
├── scripts/              # Helper and maintenance scripts
├── services/             # Docker Compose files grouped by module
│   ├── nas/              # Nextcloud, MariaDB, Redis
│   ├── monitoring/       # Prometheus, Grafana, cAdvisor
│   ├── multimedia/       # Jellyfin and related tools
│   ├── portainer/        # Portainer CE (UI for Docker)
│   └── maintenance/      # Auto updates, backups, Watchtower
├── volumes/              # Bind mounts for persistent container data
└── .env                  # Shared environment variables for Docker


Each subdirectory under `services/` contains:
- `docker-compose.yml`
- `.env` file (if needed)
- Additional configuration files (e.g., Nginx, Prometheus, MariaDB, etc.)

---

## 3. Modules Breakdown

| Module         | Purpose                                | Key Containers                         |
|----------------|-----------------------------------------|-----------------------------------------|
| `nas`          | Cloud file storage and collaboration    | Nextcloud, MariaDB, Redis               |
| `monitoring`   | System and container monitoring         | Prometheus, Grafana, cAdvisor           |
| `multimedia`   | Media server                            | Jellyfin                                |
| `portainer`    | Docker GUI management                   | Portainer CE                            |
| `maintenance`  | System automation and maintenance       | Watchtower, backup scripts              |

---

## 4. Volumes and Data Persistence

All persistent data is stored under `/opt/docker/volumes/` and mapped into containers as bind mounts. Additionally:

- Nextcloud user data is mounted from the physical NAS share at `/mnt/nas_data/`
- Monitoring data, database files, media libraries are kept isolated per module

---

## 5. Networking and Reverse Proxy

All services expose ports **internally only**. Access from the internet is routed through the **VPS reverse proxy** via a secure VPN tunnel.

Each service is available via clean subpaths:

- `https://yourdomain.com/nextcloud`
- `https://yourdomain.com/grafana`
- `https://yourdomain.com/jellyfin`

---

## 6. Docker Management

- **Portainer CE** provides a GUI for container and volume management  
- **Watchtower** (optional) checks for container updates automatically  
- Regular backups of container data and configurations are handled by cron-based scripts

---

## 7. Environment Variables and Secrets

Sensitive data is stored in `.env` files or mounted as secrets. Access to those files is restricted via Unix permissions.

---

## 8. Summary

The Docker stack is:
- **Modular** – logical grouping of services
- **Maintainable** – each module is isolated
- **Secure** – internal-only exposure, reverse proxy in charge of TLS & auth
- **Scalable** – new services can be added without affecting others
