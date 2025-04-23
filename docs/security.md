# Security Architecture

This document outlines the key security mechanisms implemented across the infrastructure, including hardening strategies, authentication, firewall rules, and intrusion prevention.

---

## 1. Overview of Security Layers

The architecture includes multiple security layers distributed across all nodes:

- **Reverse Proxy (VPS):**
  - SSL termination with Let's Encrypt
  - HTTP Basic Authentication for sensitive services
  - Fail2Ban protection against brute-force attacks
  - Rate limiting and secure HTTP headers

- **Virtual Machine:**
  - Services exposed only over VPN
  - Optional local firewall (UFW)
  - No direct internet exposure

- **Physical Server:**
  - Local-only access
  - Restricted to internal network
  - SSH access secured by key authentication

---

## 2. Authentication Mechanisms

| Service          | Authentication Type          | Notes                              |
|------------------|------------------------------|-------------------------------------|
| Nginx Reverse Proxy | HTTP Basic Auth             | For Grafana, Portainer, Cockpit     |
| Nextcloud        | Native login + optional 2FA  | User-level authentication           |
| SSH (all nodes)  | SSH key-based login          | Password login disabled             |
| Samba Shares     | Username + password          | Local user authentication           |

---

## 3. Encryption

- All public traffic is encrypted with **TLS 1.3** via Let's Encrypt  
- Internal VPN tunnel (WireGuard) encrypts all traffic between VM and VPS  
- Nextcloud data transfer secured via HTTPS  
- SSH uses modern, secure ciphers only

---

## 4. Intrusion Prevention (Fail2Ban)

Fail2Ban is installed on the VPS to monitor Nginx access logs and ban IPs with suspicious behavior:

- Detects failed login attempts to:
  - Nginx-protected services
  - Nextcloud
  - Grafana, Portainer, Cockpit
- Logs bans to `/var/log/fail2ban.log`
- Custom filters and jail configuration

---

## 5. Firewall Rules

| Node             | Firewall        | Default Policy  | Notes                           |
|------------------|------------------|------------------|----------------------------------|
| VPS              | UFW + Fail2Ban   | Deny all         | Only 22, 80, 443, VPN open       |
| Virtual Machine  | UFW (optional)   | Deny all         | Allows VPN, Samba, Docker only  |
| Physical Server  | Local firewall   | Allow LAN only   | No WAN exposure                  |

---

## 6. SSH Hardening

- Only SSH key-based login allowed
- Root login disabled (`PermitRootLogin no`)
- Non-standard SSH ports (optional)
- Rate-limited login attempts

---

## 7. Regular Updates & Maintenance

- OS packages updated regularly via `unattended-upgrades` or manual scripts  
- Docker images rebuilt with updated base layers  
- Monitoring with Prometheus/Grafana to detect anomalies

---

## 8. Summary

The infrastructure is built with a **defense-in-depth** approach:
- Secure entry points
- Encrypted communication
- Isolation between layers
- Active intrusion prevention