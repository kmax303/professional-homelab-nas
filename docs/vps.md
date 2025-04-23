# VPS Overview

This document outlines the role and configuration of the public-facing VPS server used for secure access and reverse proxying.

---

## 1. VPS Specifications

- **Provider**: AWS Lightsail (or equivalent)
- **OS**: Ubuntu Server (LTS)
- **Purpose**: Public reverse proxy and VPN endpoint

---

## 2. Assigned Resources

| Resource        | Value               |
|-----------------|---------------------|
| vCPUs           | 1                   |
| RAM             | 1 GB                |
| Disk Size       | 40 GB (default)     |
| Network         | Public IPv4, firewall-enabled |

---

## 3. Core Responsibilities

- Acts as **reverse proxy** for all services via Nginx
- Terminates HTTPS connections (SSL via Let's Encrypt)
- Handles HTTP Basic Authentication and security headers
- Runs **Fail2Ban** for brute-force protection
- Maintains a **WireGuard VPN tunnel** to the internal network

---

## 4. Services and Tools

| Component    | Purpose                                  |
|--------------|------------------------------------------|
| **Nginx**     | Reverse proxy with SSL & access control |
| **Certbot**   | Automatic SSL certificate renewal        |
| **Fail2Ban**  | Block brute-force login attempts         |
| **WireGuard** | VPN tunnel to internal VM                |

---

## 5. Reverse Proxy Configuration

- All services are accessible through subpaths of a **single domain**
  - `/nextcloud`, `/grafana`, `/portainer`, `/cockpit`, etc.
- Nginx handles:
  - HTTPS termination
  - Path-based reverse proxying
  - Rate limiting
  - CORS and CSP headers
  - HTTP Basic Auth (for selected apps)

All services run over **HTTP internally** and are secured at the proxy level.

---

## 6. VPN Configuration

- **WireGuard** is used to securely connect the VPS to the private VM network
- The VM is accessible over a virtual IP, e.g., `10.99.0.2`
- VPN interface is locked down with strict firewall rules

---

## 7. Security Hardening

- UFW configured to allow only required ports (SSH, HTTP, HTTPS)
- Root login disabled, key-based SSH enforced
- Fail2Ban active with Nginx log monitoring
- Rate limiting and anti-bot headers via Nginx

---

## 8. Summary

The VPS serves as a secure, minimal gateway to expose internal services publicly. It offloads all HTTPS and access control logic, ensuring the internal infrastructure remains isolated and protected.