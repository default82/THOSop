#!/bin/bash

# Projektname: THOSop - The Homelab Operating System on Proxmox

# 1. Überprüfung und Konfiguration der Locale-Einstellungen
echo "Überprüfe Locale-Einstellungen..."
CURRENT_LOCALE=$(locale | grep LANG= | cut -d= -f2)

if [ -z "$CURRENT_LOCALE" ] || [ "$CURRENT_LOCALE" != "en_GB.UTF-8" ]; then
    echo "Die aktuellen Locale-Einstellungen sind nicht korrekt konfiguriert oder fehlen."
    echo "Bitte wählen Sie die gewünschte Locale-Einstellung aus:"
    echo "1) en_GB.UTF-8"
    echo "2) de_DE.UTF-8"
    echo "3) Andere (manuell eingeben)"
    read -p "Wählen Sie eine Option (1-3): " locale_choice

    case $locale_choice in
        1)
            LOCALE="en_GB.UTF-8"
            ;;
        2)
            LOCALE="de_DE.UTF-8"
            ;;
        3)
            read -p "Geben Sie die gewünschte Locale ein (z.B. en_US.UTF-8): " LOCALE
            ;;
        *)
            echo "Ungültige Auswahl. Standardmäßig wird en_GB.UTF-8 verwendet."
            LOCALE="en_GB.UTF-8"
            ;;
    esac

    echo "Konfiguriere Locale auf $LOCALE..."
    sudo locale-gen $LOCALE
    sudo update-locale LANG=$LOCALE LANGUAGE=$LOCALE LC_ALL=$LOCALE
    export LANG=$LOCALE
    export LANGUAGE=$LOCALE
    export LC_ALL=$LOCALE

    echo "Locale wurde auf $LOCALE gesetzt. Ein Neustart wird empfohlen, um die Änderungen vollständig anzuwenden."
else
    echo "Locale-Einstellungen sind korrekt: $CURRENT_LOCALE"
fi

# System-Update und Installation von Abhängigkeiten
echo "Aktualisiere System und installiere Abhängigkeiten..."
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl build-essential unzip -y

# 2. Überprüfung und Installation von SQLite
echo "Überprüfe, ob SQLite installiert ist..."
if ! command -v sqlite3 &> /dev/null
then
    echo "SQLite ist nicht installiert. Installation wird durchgeführt..."
    sudo apt install sqlite3 libsqlite3-dev -y
else
    echo "SQLite ist bereits installiert."
fi

# 3. Überprüfung und Installation von Terraform
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

# 4. Überprüfung und Installation von Ansible
echo "Überprüfe, ob Ansible installiert ist..."
if ! command -v ansible &> /dev/null
then
    echo "Ansible ist nicht installiert. Installation wird durchgeführt..."
    sudo apt install ansible -y
else
    echo "Ansible ist bereits installiert."
fi

# 5. Ausgabe der Versionsnummern
echo "Überprüfe die installierten Versionen..."

echo -n "SQLite Version: "
sqlite3 --version

echo -n "Terraform Version: "
terraform version | head -n 1  # Nur die erste Zeile, die die Version enthält

echo -n "Ansible Version: "
ansible --version | head -n 1  # Nur die erste Zeile, die die Version enthält

# Abschlussmeldung
echo "THOSop: Alle Dienste wurden überprüft, installiert (falls erforderlich), und die Versionsnummern wurden ausgegeben."
