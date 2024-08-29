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
                sudo apt-get update
                sudo apt-get install -y sqlite3 libsqlite3-dev
            fi
            ;;
        "Terraform")
            if ! command -v terraform &> /dev/null; then
                TERRAFORM_VERSION=$(curl -s https://releases.hashicorp.com/terraform/ | grep -oP 'terraform_\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                curl -sSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip" -o terraform.zip
                unzip terraform.zip
                sudo mv terraform /usr/local/bin/
                rm terraform.zip
            fi
            ;;
        "Ansible")
            if ! command -v ansible &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y ansible
            fi
            ;;
        "git")
            if ! command -v git &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y git
            fi
            ;;
        "Python")
            if ! command -v python3 &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y python3 python3-pip
            fi
            ;;
        "C++ Compiler")
            if ! command -v g++ &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y g++
            fi
            ;;
        "Lighttpd")
            if ! command -v lighttpd &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y lighttpd
            fi
            ;;
        "PHP")
            if ! command -v php &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y php-cgi
                sudo lighty-enable-mod fastcgi-php
            fi
            ;;
        "Openbox")
            if ! command -v openbox &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y openbox
            fi
            ;;
        "Browser")
            if ! command -v midori &> /dev/null && ! command -v chromium &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y chromium-browser
            fi
            ;;
    esac
}

# Konfiguration von Lighttpd und PHP
configure_lighttpd() {
    echo "Richte Lighttpd für HTTPS ein..." >&3

    # SSL-Zertifikat erstellen
    sudo mkdir -p /etc/lighttpd/certs
    sudo openssl req -x509 -newkey rsa:4096 -keyout /etc/lighttpd/certs/lighttpd.pem -out /etc/lighttpd/certs/lighttpd.pem -days 365 -nodes -subj "/CN=localhost"

    # Lighttpd-Konfiguration anpassen
    sudo tee /etc/lighttpd/lighttpd.conf > /dev/null <<EOL
server.modules += ("mod_openssl", "mod_fastcgi")
server.document-root = "/var/www/html"
ssl.engine = "enable"
ssl.pemfile = "/etc/lighttpd/certs/lighttpd.pem"

fastcgi.server = ( ".php" =>
    ( "localhost" =>
        (
            "socket" => "/var/run/lighttpd/php.socket",
            "bin-path" => "/usr/bin/php-cgi"
        )
    )
)
EOL

    sudo systemctl restart lighttpd
    sudo systemctl enable lighttpd
}

# Openbox und Browser im Kiosk-Modus konfigurieren
configure_openbox() {
    echo "Richte Openbox Autostart-Konfiguration ein..." >&3
    mkdir -p ~/.config/openbox
    tee ~/.config/openbox/autostart > /dev/null <<EOL
chromium-browser --kiosk --app=http://localhost &
EOL

    sudo systemctl set-default graphical.target
    sudo systemctl enable lightdm
}

# Generische Webseite erstellen
create_generic_website() {
    echo "Erstelle generische Webseite..." >&3
    sudo mkdir -p /var/www/html
    sudo tee /var/www/html/index.php > /dev/null <<EOL
<?php phpinfo(); ?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Willkommen</title>
</head>
<body>
    <h1>Willkommen auf der generischen Webseite!</h1>
    <p>Diese Webseite wurde automatisch generiert.</p>
</body>
</html>
EOL
}

# Liste der zu installierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "git" "Python" "C++ Compiler" "Lighttpd" "PHP" "Openbox" "Browser")

# Installation der Dienste
for SERVICE in "${SERVICES[@]}"; do
    echo "Installiere $SERVICE..." >&3
    install_service "$SERVICE"
done

# Konfigurationen durchführen
configure_lighttpd
configure_openbox
create_generic_website

echo "Installations- und Konfigurationsvorgang abgeschlossen." >&3
