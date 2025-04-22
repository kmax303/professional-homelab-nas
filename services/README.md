# Docker Services

This directory contains all modular Docker Compose service definitions grouped by functionality.

Modules:
- `nas/` — Self-hosted cloud and file sync (Nextcloud stack)
- `monitoring/` — Prometheus, Grafana, cAdvisor for system observability
- `multimedia/` — Jellyfin-based media server stack
- `portainer/` — Docker web UI management via Portainer
- `maintenance/` — Auxiliary tools for system upkeep
- `reverse-proxy/` — Nginx reverse proxy with SSL, Basic Auth, Fail2Ban protection

Each subfolder contains:
- `docker-compose.yml`
- Environment files
- Configuration templates
- README with module details
