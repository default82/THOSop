#!/bin/bash

# Update system and install dependencies
echo "Aktualisiere System und installiere Abhängigkeiten..."
sudo apt-get update && sudo apt-get upgrade -y

# Fix locale issues
echo "Überprüfe und korrigiere Locale-Einstellungen..."
sudo locale-gen de_DE.UTF-8 en_GB.UTF-8
sudo update-locale LANG=de_DE.UTF-8
export LANG=de_DE.UTF-8

# Check if SQLite is installed
echo "Überprüfe, ob SQLite installiert ist..."
if ! command -v sqlite3 &> /dev/null
then
    echo "SQLite ist nicht installiert. Installation wird durchgeführt..."
    sudo apt-get install -y sqlite3 libsqlite3-dev
else
    echo "SQLite ist bereits installiert."
fi

# Check if Terraform is installed
echo "Überprüfe, ob Terraform installiert ist..."
if ! command -v terraform &> /dev/null
then
    echo "Terraform ist nicht installiert. Installation wird durchgeführt..."
    wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_arm64.zip
    unzip terraform_1.5.0_linux_arm64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.5.0_linux_arm64.zip
else
    echo "Terraform ist bereits installiert."
fi

# Check if Ansible is installed
echo "Überprüfe, ob Ansible installiert ist..."
if ! command -v ansible &> /dev/null
then
    echo "Ansible ist nicht installiert. Installation wird durchgeführt..."
    sudo apt-get install -y ansible
else
    echo "Ansible ist bereits installiert."
fi

# Verify installations and check versions
echo "Überprüfe die installierten Versionen..."
sqlite3 --version
terraform -v
ansible --version

echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), und die Versionsnummern wurden ausgegeben."
