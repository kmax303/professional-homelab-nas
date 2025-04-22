# Reverse Proxy Module

This module provides a secure and unified HTTPS entry point to all internal services using Nginx.

Components:
- **Nginx** configured with:
  - Reverse proxy rules for all services
  - SSL termination (Let's Encrypt)
  - HTTP Basic Authentication (for services like Grafana, Portainer, nextcloud)
  - Rate limiting and security headers
- **Fail2Ban** for brute-force protection, monitoring Nginx logs
- **Certbot** (optional) for automatic certificate renewal

Used to expose services over a single public domain with clean subpaths (e.g., `/nextcloud`, `/grafana`, `/portainer`).
