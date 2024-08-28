#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_install.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Fortschrittsanzeige
show_progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  %s" "$spinstr" "$2" >&3
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b" >&3
    done
    printf "    \b\b\b\b" >&3
    echo "" >&3
}

# Funktion zur Überprüfung der neuesten Terraform-Version
get_latest_terraform_version() {
    curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -Po '"current_version":.*?[^\\]",' | sed 's/"current_version":"\(.*\)",/\1/'
}

# Funktion zur Installation von Terraform
install_terraform() {
    local version=$1
    echo "Installiere Terraform Version $version..." >&3
    
    wget https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_arm64.zip
    unzip terraform_${version}_linux_arm64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${version}_linux_arm64.zip
    if ! terraform -version &> /dev/null; then
        echo "Fehler: Terraform konnte nicht korrekt installiert werden." >&3
        exit 1
    fi
}

# Funktion zum Testen der installierten Software
test_installation() {
    echo "Überprüfe die Installation von $1..." >&3

    case $1 in
        "SQLite")
            if sqlite3 --version &> /dev/null; then
                echo "SQLite wurde erfolgreich installiert und funktioniert." >&3
            else
                echo "Fehler: SQLite konnte nicht korrekt installiert werden." >&3
                exit 1
            fi
            ;;
        "Terraform")
            if terraform -version &> /dev/null; then
                echo "Terraform wurde erfolgreich installiert und funktioniert." >&3
            else
                echo "Fehler: Terraform konnte nicht korrekt installiert werden." >&3
                exit 1
            fi
            ;;
        "Ansible")
            if ansible --version &> /dev/null; then
                echo "Ansible wurde erfolgreich installiert und funktioniert." >&3
            else
                echo "Fehler: Ansible konnte nicht korrekt installiert werden." >&3
                exit 1
            fi
            ;;
    esac
}

# System aktualisieren und Abhängigkeiten installieren
echo "Aktualisiere System und installiere Abhängigkeiten..." >&3
{
    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y wget curl unzip
} &
show_progress $! "Aktualisiere System und installiere Abhängigkeiten..."

# Überprüfung und Korrektur der Locale-Einstellungen
echo "Überprüfe und korrigiere Locale-Einstellungen..." >&3
{
    sudo locale-gen de_DE.UTF-8 en_GB.UTF-8
    sudo update-locale LANG=de_DE.UTF-8
} &
show_progress $! "Überprüfe und korrigiere Locale-Einstellungen..."

# Überprüfen, ob SQLite installiert ist
echo "Überprüfe, ob SQLite installiert ist..." >&3
{
    if ! command -v sqlite3 &> /dev/null; then
        sudo apt-get install -y sqlite3 libsqlite3-dev
    fi
    test_installation "SQLite"
} &
show_progress $! "Überprüfe SQLite-Installation..."

# Überprüfen, ob Terraform installiert ist und auf die neueste Version aktualisieren
echo "Überprüfe, ob Terraform installiert ist..." >&3
{
    installed_version=$(terraform -version | head -n1 | awk '{print $2}' | sed 's/v//')
    latest_version=$(get_latest_terraform_version)
    if [[ "$installed_version" != "$latest_version" ]]; then
        install_terraform $latest_version
    fi
    test_installation "Terraform"
} &
show_progress $! "Überprüfe Terraform-Installation..."

# Überprüfen, ob Ansible installiert ist
echo "Überprüfe, ob Ansible installiert ist..." >&3
{
    if ! command -v ansible &> /dev/null; then
        sudo apt-get install -y ansible
    fi
    test_installation "Ansible"
} &
show_progress $! "Überprüfe Ansible-Installation..."

# Installierte Versionen anzeigen
echo "Überprüfe die installierten Versionen..." >&3
{
    sqlite3 --version
    terraform -version
    ansible --version
} &
show_progress $! "Zeige installierte Versionen..."

echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), getestet und die Versionsnummern wurden ausgegeben." >&3
