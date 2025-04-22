#!/bin/bash

MONITOR_DIR="/mnt/nas_data"
CONTAINER_NAME="nextcloud"
CHECK_INTERVAL=5
PREVIOUS_FILE_LIST="/tmp/previous_files.txt"

# Funkcja uruchamiająca komendę OCC
run_occasionally() {
  echo "[$(date)] Running occ files:scan..."
  docker exec -u www-data "$CONTAINER_NAME" php /var/www/html/occ files:scan --all >> /var/log/nextcloud_scan.log 2>&1
}

# Funkcja do sprawdzania stabilności pliku (rozmiar nie zmienia się)
is_file_stable() {
  local file="$1"
  [ -f "$file" ] || return 1
  local size1=$(stat -c%s "$file" 2>/dev/null || echo 0)
  sleep 5  # Czekamy chwilę na stabilizację
  local size2=$(stat -c%s "$file" 2>/dev/null || echo 0)
  if [[ "$size1" -eq "$size2" ]]; then
    sleep 5  # Czekamy dodatkowe 5 sekund
    size2=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if [[ "$size1" -eq "$size2" ]]; then
      return 0  # Plik stabilny
    fi
  fi
  return 1  # Plik wciąż się zmienia
}

# Zainicjalizowanie poprzedniej listy plików, jeśli jeszcze nie istnieje
[ -f "$PREVIOUS_FILE_LIST" ] || find "$MONITOR_DIR" -type f | sort > "$PREVIOUS_FILE_LIST"

# Inicjalizacja LAST_CHECK na początek
if [ -z "$LAST_CHECK" ]; then
  LAST_CHECK=$(date +%s)
fi

while true; do
  # Tworzymy tymczasową listę plików
  CURRENT_FILE_LIST=$(mktemp)
  find "$MONITOR_DIR" -type f | sort > "$CURRENT_FILE_LIST"  # Sortowanie plików

  # Wykrywanie nowych plików (nie zależnie od daty modyfikacji)
  stable_found=false
  while IFS= read -r file; do
    # Sprawdzamy, czy plik jest nowy (nie był wcześniej na liście)
    if ! grep -q "$file" "$PREVIOUS_FILE_LIST"; then
      # Sprawdzamy, czy plik jest stabilny (rozmiar nie zmienia się)
      if is_file_stable "$file"; then
        stable_found=true
        break
      fi
    fi
  done < "$CURRENT_FILE_LIST"

  # Wykrywanie usuniętych plików
  deleted_found=false
  mapfile -t DELETED_FILES < <(comm -23 "$PREVIOUS_FILE_LIST" "$CURRENT_FILE_LIST")
  if [ "${#DELETED_FILES[@]}" -gt 0 ]; then
    echo "[$(date)] Detected deleted files:"
    printf '%s\n' "${DELETED_FILES[@]}"
    deleted_found=true
  fi

  # Jeśli wykryto zmiany lub usunięcia, uruchom polecenie OCC
  if $stable_found || $deleted_found; then
    run_occasionally
  fi

  # Zaktualizowanie poprzedniej listy plików
  cp "$CURRENT_FILE_LIST" "$PREVIOUS_FILE_LIST"
  rm "$CURRENT_FILE_LIST"

  # Zaktualizowanie czasu ostatniego sprawdzenia
  LAST_CHECK=$(date +%s)

  # Czekamy przed kolejnym sprawdzeniem
  sleep $CHECK_INTERVAL
done

