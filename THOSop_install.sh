#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_install.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Funktion zur Überprüfung der neuesten Terraform-Version
get_latest_terraform_version() {
    curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -Po '"current_version":.*?[^\\]",' | sed 's/"current_version":"\(.*\)",/\1/'
}

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
            installed_version=$(terraform -version | head -n1 | awk '{print $2}' | sed 's/v//')
            latest_version=$(get_latest_terraform_version)
            if [[ "$installed_version" != "$latest_version" ]]; then
                wget -q https://releases.hashicorp.com/terraform/${latest_version}/terraform_${latest_version}_linux_arm64.zip
                unzip -o terraform_${latest_version}_linux_arm64.zip >/dev/null
                sudo mv terraform /usr/local/bin/
                rm terraform_${latest_version}_linux_arm64.zip
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

# Funktion zum Testen der installierten Software
test_installation() {
    local service=$1
    case $service in
        "SQLite")
            command -v sqlite3 &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "Terraform")
            command -v terraform &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "Ansible")
            command -v ansible &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "nmap")
            command -v nmap &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "git")
            command -v git &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "Python")
            command -v python3 &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
        "C++ Compiler")
            command -v g++ &> /dev/null && echo "$service wurde erfolgreich installiert und funktioniert." >&3
            ;;
    esac
}

# Liste der zu installierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "nmap" "git" "Python" "C++ Compiler")

# System aktualisieren und Abhängigkeiten installieren
echo "Aktualisiere System und installiere Abhängigkeiten..." >&3
{
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y wget curl unzip build-essential
}

# Überprüfung und Korrektur der Locale-Einstellungen
echo "Überprüfe und korrigiere Locale-Einstellungen..." >&3
{
    sudo locale-gen de_DE.UTF-8 en_GB.UTF-8
    sudo update-locale LANG=de_DE.UTF-8
}

# Installation und Überprüfung der Dienste
for SERVICE in "${SERVICES[@]}"; do
    echo "Überprüfe, ob $SERVICE installiert ist..." >&3
    install_service "$SERVICE"
    test_installation "$SERVICE"
done

# Installierte Versionen anzeigen
echo "Überprüfe die installierten Versionen..." >&3
{
    sqlite3 --version
    terraform -version
    ansible --version
    nmap --version
    git --version
    python3 --version
    g++ --version
}

echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), getestet und die Versionsnummern wurden ausgegeben." >&3
