#!/bin/bash

# Projektname: THOSop - The Homelab Operating System on Proxmox

# 1. Entfernen von SQLite
echo "Deinstalliere SQLite..."
if command -v sqlite3 &> /dev/null
then
    sudo apt remove --purge sqlite3 libsqlite3-dev -y
    sudo apt autoremove -y
    sudo apt clean
    echo "SQLite wurde deinstalliert."
else
    echo "SQLite ist nicht installiert."
fi

# 2. Entfernen von Terraform
echo "Deinstalliere Terraform..."
if command -v terraform &> /dev/null
then
    sudo rm /usr/local/bin/terraform
    echo "Terraform wurde deinstalliert."
else
    echo "Terraform ist nicht installiert."
fi

# 3. Entfernen von Ansible
echo "Deinstalliere Ansible..."
if command -v ansible &> /dev/null
then
    sudo apt remove --purge ansible -y
    sudo apt autoremove -y
    sudo apt clean
    echo "Ansible wurde deinstalliert."
else
    echo "Ansible ist nicht installiert."
fi

# 4. Bereinigung von Konfigurationsdateien und Verzeichnissen
echo "Bereinige Konfigurationsdateien und Verzeichnisse..."

# Löschen des Datenbankverzeichnisses, falls vorhanden
DB_PATH="/var/lib/secure_db"
if [ -d "$DB_PATH" ]; then
    sudo rm -rf "$DB_PATH"
    echo "Datenbankverzeichnis wurde entfernt."
fi

# Entfernen von temporären Dateien und Installationsartefakten
sudo rm -f terraform_*.zip
sudo rm -rf /path/to/your/THOSop_installation  # Ersetze dies mit dem tatsächlichen Pfad

echo "Bereinigung abgeschlossen."

# Abschlussmeldung
echo "THOSop: Alle installierten Dienste wurden deinstalliert. Git bleibt installiert."

# Eine kleine Änderung zum Testen
