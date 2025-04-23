# Network Architecture

This document describes the complete networking layout of the project, including the role of each node, VPN configuration, and routing rules for internal and external communication.

---

## 1. Topology Overview

The infrastructure is composed of three main layers:

- **Physical Server (local)**  
  - Hosts KVM virtual machines  
  - Shares storage via Samba  
  - Manages VM backups

- **Virtual Machine (internal services)**  
  - Hosts all containerized services (NAS, monitoring, multimedia, etc.)  
  - Connected to the physical server via LAN  
  - Connected to VPS via VPN tunnel (WireGuard)

- **VPS (public access)**  
  - Hosts Nginx reverse proxy  
  - Provides HTTPS access to selected services  
  - Integrates Fail2Ban and SSL certificates

---

## 2. VPN Configuration

- A **WireGuard VPN tunnel** connects the VPS and the virtual machine.  
- The VM has a private VPN IP (e.g., `10.99.0.2`)  
- The VPS communicates with internal services exclusively through this VPN.

---

## 3. Public Routing Flow

<pre> 
  User Browser
    │
    ▼
  VPS (Nginx Reverse Proxy + Fail2Ban)
    │
    │ VPN Tunnel (WireGuard)
    ▼
  Virtual Machine (Dockerized Services)
</pre>


- External users connect to `https://domain.com/<service>`
- Nginx terminates SSL and applies HTTP Basic Auth, security headers, rate limits, etc.
- Requests are forwarded via VPN to the Docker services running in the VM

---

## 4. Internal Communication

- The physical server and VM communicate over the local LAN (`192.168.x.x`)
- Services like Samba and KVM management are available locally
- Backups and monitoring operate internally, without public exposure

---

## 5. Firewall and Access Rules

| Component        | Firewall     | Exposed Ports                       |
|------------------|--------------|-------------------------------------|
| VPS              | UFW + Fail2Ban | 22 (SSH), 80/443 (HTTP/HTTPS), VPN |
| Virtual Machine  | UFW (optional) | Restricted to VPN and LAN          |
| Physical Server  | LAN Only      | Samba, SSH, KVM management          |

---

## 6. Domain and SSL

- A custom domain points to the public IP of the VPS  
- All services are exposed using **clean subpaths** (e.g. `/grafana`, `/nextcloud`)  
- SSL is handled via **Let's Encrypt + Certbot**  
- Certificates are automatically renewed

---

## 7. Summary

This networking model ensures:
- Full isolation of internal services
- Secure public access via hardened VPS
- Centralized traffic control with reverse proxy
- Encrypted communication across the board
