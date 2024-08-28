#!/bin/bash

# Funktion zur Überprüfung der neuesten Terraform-Version
get_latest_terraform_version() {
    curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -Po '"current_version":.*?[^\\]",' | sed 's/"current_version":"\(.*\)",/\1/'
}

# Funktion zur Installation von Terraform
install_terraform() {
    local version=$1
    echo "Installiere Terraform Version $version..."
    
    wget https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_arm64.zip
    unzip terraform_${version}_linux_arm64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${version}_linux_arm64.zip
}

# System aktualisieren und Abhängigkeiten installieren
echo "Aktualisiere System und installiere Abhängigkeiten..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y wget curl unzip

# Überprüfung und Korrektur der Locale-Einstellungen
echo "Überprüfe und korrigiere Locale-Einstellungen..."
sudo locale-gen de_DE.UTF-8 en_GB.UTF-8
sudo update-locale LANG=de_DE.UTF-8

# Überprüfen, ob SQLite installiert ist
echo "Überprüfe, ob SQLite installiert ist..."
if ! command -v sqlite3 &> /dev/null; then
    echo "SQLite ist nicht installiert. Installation wird durchgeführt..."
    sudo apt-get install -y sqlite3 libsqlite3-dev
else
    echo "SQLite ist bereits installiert."
fi

# Überprüfen, ob Terraform installiert ist und auf die neueste Version aktualisieren
echo "Überprüfe, ob Terraform installiert ist..."
installed_version=$(terraform -version | head -n1 | awk '{print $2}' | sed 's/v//')
latest_version=$(get_latest_terraform_version)

if [[ "$installed_version" != "$latest_version" ]]; then
    echo "Aktuelle Terraform-Version ist veraltet. Aktualisiere auf Version $latest_version..."
    install_terraform $latest_version
else
    echo "Terraform ist bereits auf dem neuesten Stand."
fi

# Überprüfen, ob Ansible installiert ist
echo "Überprüfe, ob Ansible installiert ist..."
if ! command -v ansible &> /dev/null; then
    echo "Ansible ist nicht installiert. Installation wird durchgeführt..."
    sudo apt-get install -y ansible
else
    echo "Ansible ist bereits installiert."
fi

# Installierte Versionen anzeigen
echo "Überprüfe die installierten Versionen..."
sqlite3 --version
terraform -version
ansible --version

echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), und die Versionsnummern wurden ausgegeben."
