# Backup Strategy

This document outlines the backup mechanisms used across the infrastructure to ensure data integrity, disaster recovery, and long-term resilience.

---

## 1. Overview

Backups are managed at three distinct levels:

1. **Virtual Machine Level** – Full and incremental snapshots of the VM using `qemu-img`
2. **Service Level (Docker)** – Individual service data stored in mounted volumes
3. **Remote Sync** – Encrypted offsite backups (future feature)

---

## 2. Virtual Machine Backups

The entire Docker stack runs inside a KVM-based virtual machine hosted on the **physical Ubuntu Server**. This VM is regularly backed up using the following process:

- **Tooling**: Native `qemu-img` commands
- **Types**:
- **Full backup** – once weekly
- **Incremental snapshots** – daily
- **Includes**:
- VM disk image (`.qcow2`)
- XML VM definition file (libvirt config)
- **Storage**: Saved to `/mnt/backups/vm/` on the physical server
- **Retention Policy**: Old backups auto-pruned based on configurable retention rules

The backup script supports:
- VM pause/resume for consistency
- Logging and error reporting
- Cron-based automation

---

## 3. Container Data Backups

Each Docker module stores persistent data in bind-mounted volumes located at: /opt/docker/volumes/


A custom backup script (stored in `/opt/docker/scripts/`) performs:

- **Compression**: `.tar.gz` archives per module (e.g., `nas.tar.gz`, `monitoring.tar.gz`)
- **Rotation**: Number of archives retained is configurable
- **Exclusions**: Temporary files, logs, caches
- **Schedule**: Daily via `cron`

Backups are stored locally in `/mnt/backups/docker/`, and optionally synced to external storage.

---

## 4. Nextcloud User Data

User files for Nextcloud are mounted directly from the **NAS share**: /mnt/nas_data/


This share is backed up **outside of Docker**, using standard file-based backup tools (e.g., `rsync`, `borg`, or `restic`) as part of the physical server’s backup process.

---

## 5. Backup Verification

Planned future improvements:

- **Automated restore tests**
- **Backup integrity checksums (SHA256)**
- **Email or Telegram notifications for backup success/failure**

---

## 6. Future Improvements

- **Remote encrypted sync** (e.g., Backblaze B2, Wasabi, or a second VPS)
- **UI integration** with Portainer or custom dashboard for backup status
- **Restic/Borg integration** for deduplication and integrity

---

## 7. Summary

| Level         | Method            | Tooling       | Frequency     |
|---------------|-------------------|----------------|----------------|
| VM            | Full + delta      | qemu-img       | Daily/Weekly   |
| Docker data   | Volume backups    | tar + cron     | Daily          |
| Nextcloud     | External volume   | rsync/borg     | Daily/Weekly   |

All backups are centralized under the physical host and stored in a structured, rotating system for maximum reliability.

