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
            if command -v sqlite3 &> /dev/null; then
                sudo apt-get remove --purge -y sqlite3 libsqlite3-dev
                sudo apt-get autoremove -y
            fi
            ;;
        "Terraform")
            if command -v terraform &> /dev/null; then
                sudo rm /usr/local/bin/terraform
            fi
            ;;
        "Ansible")
            if command -v ansible &> /dev/null; then
                sudo apt-get remove --purge -y ansible
                sudo apt-get autoremove -y
            fi
            ;;
        "nmap")
            if command -v nmap &> /dev/null; then
                sudo apt-get remove --purge -y nmap
                sudo apt-get autoremove -y
            fi
            ;;
        "git")
            if command -v git &> /dev/null; then
                sudo apt-get remove --purge -y git
                sudo apt-get autoremove -y
            fi
            ;;
        "Python")
            if command -v python3 &> /dev/null; then
                sudo apt-get remove --purge -y python3 python3-pip
                sudo apt-get autoremove -y
            fi
            ;;
        "C++ Compiler")
            if command -v g++ &> /dev/null; then
                sudo apt-get remove --purge -y g++
                sudo apt-get autoremove -y
            fi
            ;;
    esac
}

# Liste der zu deinstallierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "nmap" "git" "Python" "C++ Compiler")

# Deinstallation der Dienste
for SERVICE in "${SERVICES[@]}"; do
    echo "Überprüfe, ob $SERVICE deinstalliert wird..." >&3
    uninstall_service "$SERVICE"
done

echo "THOSop: Alle ausgewählten Dienste wurden deinstalliert und das System bereinigt." >&3
