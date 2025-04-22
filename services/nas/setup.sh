#!/bin/bash

set -e

echo ">> Uruchamianie stacka NAS..."
docker compose --env-file .env up -d

echo ">> Gotowe. Dostęp do Nextcloud: http://localhost:${NEXTCLOUD_PORT}"

