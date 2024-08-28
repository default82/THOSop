#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_install.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Funktion zur Installation eines Dienstes
install_service() {
    local service=$1
    
    case $service in
        "SQLite")
            if ! command -v sqlite3 &> /dev/null; then
                sudo apt-get install -y sqlite3 libsqlite3-dev
            fi
            ;;
        "Terraform")
            if ! command -v terraform &> /dev/null; then
                curl -sSL "https://releases.hashicorp.com/terraform/$(curl -sSL https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)/terraform_$(curl -sSL https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)_linux_arm64.zip" -o terraform.zip
                unzip terraform.zip
                sudo mv terraform /usr/local/bin/
                rm terraform.zip
            fi
            ;;
        "Ansible")
            if ! command -v ansible &> /dev/null; then
                sudo apt-get install -y ansible
            fi
            ;;
        "nmap")
            if ! command -v nmap &> /dev/null; then
                sudo apt-get install -y nmap
            fi
            ;;
        "git")
            if ! command -v git &> /dev/null; then
                sudo apt-get install -y git
            fi
            ;;
        "Python")
            if ! command -v python3 &> /dev/null; then
                sudo apt-get install -y python3 python3-pip
            fi
            ;;
        "C++ Compiler")
            if ! command -v g++ &> /dev/null; then
                sudo apt-get install -y g++
            fi
            ;;
    esac
}

# Funktion, um das Netzwerk nach aktiven Maschinen zu scannen
network_scan() {
    echo "Starte Netzwerk-Scan..."
    IP_ADDR=$(hostname -I | awk '{print $1}')
    SUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
    OUTPUT_FILE="/var/log/network_scan_results.txt"

    echo "Scanne Netzwerk $SUBNET von IP $IP_ADDR..."
    nmap -O -sV $SUBNET -oN "$OUTPUT_FILE"

    echo "Netzwerk-Scan abgeschlossen. Ergebnisse gespeichert in $OUTPUT_FILE."
}

# Liste der zu installierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "nmap" "git" "Python" "C++ Compiler")

# Installation der Dienste
for SERVICE in "${SERVICES[@]}"; do
    echo "Überprüfe, ob $SERVICE installiert ist..." >&3
    install_service "$SERVICE"
done

# Netzwerk-Scan durchführen
network_scan

echo "THOSop: Alle ausgewählten Dienste wurden installiert und konfiguriert. Netzwerk-Scan wurde durchgeführt." >&3
