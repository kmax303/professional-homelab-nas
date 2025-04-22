#!/bin/bash

VM_NAME="yours vm disc name"
BACKUP_DIR="/mnt/backup/vm/${VM_NAME}/"
BASE_IMAGE="/opt/vm/machines/${VM_NAME}/${VM_NAME}.qcow2"
DATE=$(date +%Y%m%d)
LOG_FILE="/var/log/vm_backup.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

ensure_vm_running() {
    VM_STATE=$(virsh domstate "$VM_NAME")
    if [[ "$VM_STATE" != "running" && "$VM_STATE" != "shut off" ]]; then
        log "Uruchamianie maszyny wirtualnej: $VM_NAME..."
        virsh start "$VM_NAME"
    fi
}

trap "ensure_vm_running" ERR

mkdir -p "$BACKUP_DIR"

VM_STATE=$(virsh domstate "$VM_NAME")
if [[ "$VM_STATE" != "shut off" && "$VM_STATE" != "crashed" ]]; then
    log "Wyłączanie maszyny wirtualnej: $VM_NAME..."
    virsh shutdown "$VM_NAME"
    log "Czekam na wyłączenie maszyny..."
    while [[ "$(virsh domstate "$VM_NAME")" != "shut off" && "$(virsh domstate "$VM_NAME")" != "crashed" ]]; do
        sleep 5
    done
else
    log "Maszyna wirtualna jest już wyłączona."
fi

LAST_FULL_BACKUP=$(find "$BACKUP_DIR" -type f -name "${VM_NAME}_full_*.qcow2" | sort -r | head -n 1)
CREATE_FULL=false

if [[ -z "$LAST_FULL_BACKUP" ]]; then
    CREATE_FULL=true
else
    LAST_FULL_DATE=$(echo "$LAST_FULL_BACKUP" | grep -oE '[0-9]{8}' | head -n 1)
    DAYS_SINCE_LAST_FULL=$(( ( $(date -d "$DATE" +%s) - $(date -d "$LAST_FULL_DATE" +%s) ) / 86400 ))
    if (( DAYS_SINCE_LAST_FULL >= 7 )); then
        CREATE_FULL=true
    fi
fi

if $CREATE_FULL; then
    log "Tworzenie pełnego backupu..."
    FULL_BACKUP="${BACKUP_DIR}/${VM_NAME}_full_${DATE}.qcow2"
    cp "$BASE_IMAGE" "$FULL_BACKUP"
else
    LAST_INCREMENTAL_BACKUP=$(find "$BACKUP_DIR" -type f -name "${VM_NAME}_inc_*.qcow2" | sort -r | head -n 1)
    log "Tworzenie przyrostowego backupu..."
    INCREMENTAL_BACKUP="${BACKUP_DIR}/${VM_NAME}_inc_${DATE}.qcow2"
    if [[ -z "$LAST_INCREMENTAL_BACKUP" ]]; then
        qemu-img create -f qcow2 -b "$LAST_FULL_BACKUP" -F qcow2 "$INCREMENTAL_BACKUP"
    else
        qemu-img create -f qcow2 -b "$LAST_INCREMENTAL_BACKUP" -F qcow2 "$INCREMENTAL_BACKUP"
    fi
fi

log "Usuwanie przyrostowych backupów starszych niż 7 dni..."
find "$BACKUP_DIR" -type f -name "${VM_NAME}_inc_*.qcow2" -mtime +7 -exec rm {} \;

log "Usuwanie pełnych backupów starszych niż 28 dni..."
find "$BACKUP_DIR" -type f -name "${VM_NAME}_full_*.qcow2" -mtime +28 -exec rm {} \;

log "Tworzenie backupu konfiguracji maszyny..."
NEW_CONFIG_BACKUP="${BACKUP_DIR}/${VM_NAME}_config_${DATE}.xml"
virsh dumpxml "$VM_NAME" > "$NEW_CONFIG_BACKUP"

log "Usuwanie konfiguracji starszych niż 7 dni..."
find "$BACKUP_DIR" -type f -name "${VM_NAME}_config_*.xml" -mtime +7 -exec rm {} \;

log "Uruchamianie maszyny wirtualnej po zakończeniu backupu..."
virsh start "$VM_NAME"

log "Backup zakończony."

