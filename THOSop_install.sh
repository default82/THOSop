#!/bin/bash

# Projektname: THOSop - The Homelab Operating System on Proxmox

# System-Update und Installation von Abhängigkeiten
echo "Aktualisiere System und installiere Abhängigkeiten..."
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl build-essential unzip -y

# 1. Überprüfung und Installation von SQLite
echo "Überprüfe, ob SQLite installiert ist..."
if ! command -v sqlite3 &> /dev/null
then
    echo "SQLite ist nicht installiert. Installation wird durchgeführt..."
    sudo apt install sqlite3 libsqlite3-dev -y
else
    echo "SQLite ist bereits installiert."
fi

# 2. Überprüfung und Installation von Terraform
echo "Überprüfe, ob Terraform installiert ist..."
if ! command -v terraform &> /dev/null
then
    echo "Terraform ist nicht installiert. Installation wird durchgeführt..."
    # Herunterladen und Installation von Terraform für ARM64
    TERRAFORM_VERSION="1.5.0"  # Gib hier die gewünschte Version an
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip
    unzip terraform_${TERRAFORM_VERSION}_linux_arm64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_${TERRAFORM_VERSION}_linux_arm64.zip
else
    echo "Terraform ist bereits installiert."
fi

# 3. Überprüfung und Installation von Ansible
echo "Überprüfe, ob Ansible installiert ist..."
if ! command -v ansible &> /dev/null
then
    echo "Ansible ist nicht installiert. Installation wird durchgeführt..."
    sudo apt install ansible -y
else
    echo "Ansible ist bereits installiert."
fi

# 4. Ausgabe der Versionsnummern
echo "Überprüfe die installierten Versionen..."

echo -n "SQLite Version: "
sqlite3 --version

echo -n "Terraform Version: "
terraform version | head -n 1  # Nur die erste Zeile, die die Version enthält

echo -n "Ansible Version: "
ansible --version | head -n 1  # Nur die erste Zeile, die die Version enthält

# Abschlussmeldung
echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), und die Versionsnummern wurden ausgegeben."
