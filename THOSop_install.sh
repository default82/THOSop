#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_uninstall.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Funktion zur Deinstallation eines Dienstes
uninstall_service() {
    local service=$1
    
    case $service in
        "SQLite")
            sudo apt-get remove -y sqlite3 libsqlite3-dev
            ;;
        "Terraform")
            sudo rm -f /usr/local/bin/terraform
            ;;
        "Ansible")
            sudo apt-get remove -y ansible
            ;;
        "git")
            sudo apt-get remove -y git
            ;;
        "Python")
            sudo apt-get remove -y python3 python3-pip
            ;;
        "C++ Compiler")
            sudo apt-get remove -y g++
            ;;
        "Lighttpd")
            sudo apt-get remove -y lighttpd
            sudo rm -rf /etc/lighttpd /var/www/html
            ;;
        "PHP")
            sudo apt-get remove -y php-cgi
            ;;
        "Openbox")
            sudo apt-get remove -y openbox
            ;;
        "Browser")
            sudo apt-get remove -y chromium-browser
            ;;
    esac
}

# Liste der zu deinstallierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "git" "Python" "C++ Compiler" "Lighttpd" "PHP" "Openbox" "Browser")

# Deinstallation der Dienste
for SERVICE in "${SERVICES[@]}"; do
    echo "Deinstalliere $SERVICE..." >&3
    uninstall_service "$SERVICE"
done

echo "Deinstallationsvorgang abgeschlossen." >&3
