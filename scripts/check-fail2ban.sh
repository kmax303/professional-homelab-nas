#!/bin/bash

echo "📦 Sprawdzanie aktywnych jaili Fail2Ban..."
echo "-------------------------------------------"

if ! command -v fail2ban-client &> /dev/null; then
    echo "❌ Brak polecenia fail2ban-client. Upewnij się, że Fail2Ban jest zainstalowany."
    exit 1
fi

JAILS=$(fail2ban-client status | grep "Jail list" | cut -d: -f2 | tr ',' ' ')

for JAIL in $JAILS; do
    JAIL=$(echo $JAIL | xargs)

    echo ""
    echo "🔒 Jail: $JAIL"
    echo "-------------------------------------------"
    fail2ban-client status "$JAIL"

    echo -n "📝 logpath: "

    # Szukaj pliku konfiguracji jaila
    FOUND_LOGPATH=""

    for CONF_FILE in $(find /etc/fail2ban/jail.d/ -name "*.conf" 2>/dev/null); do
        if grep -q "\[$JAIL\]" "$CONF_FILE"; then
            LOG_PATH=$(awk -v jail="[$JAIL]" '
                $0 == jail {found=1; next}
                found && $1 == "logpath" {print $3; exit}
            ' "$CONF_FILE")
            if [ -n "$LOG_PATH" ]; then
                FOUND_LOGPATH=$LOG_PATH
                echo "$LOG_PATH (z $CONF_FILE)"
                break
            fi
        fi
    done

    if [ -z "$FOUND_LOGPATH" ]; then
        echo "Nie znaleziono w plikach konfiguracyjnych"
    fi

    echo "🚫 Zbanowane IP:"
    fail2ban-client status "$JAIL" | grep 'Banned IP' || echo "Brak"
done
