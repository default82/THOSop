#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_install.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Funktion zum Loggen
log() {
    echo "$1" >&3
    echo "$1" >> $LOGFILE
}

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
        "nmap")
            if ! command -v nmap &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y nmap
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
        "Openbox")
            if ! command -v openbox &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y openbox
            fi
            ;;
        "Midori")
            if ! command -v midori &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y midori
            fi
            ;;
        "Lighttpd")
            if ! command -v lighttpd &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y lighttpd php-cgi openssl
                sudo lighty-enable-mod fastcgi-php
                sudo service lighttpd force-reload
            fi
            ;;
    esac
}

# Funktion zur Einrichtung von Openbox und Midori
setup_openbox_midori() {
    log "Richte Openbox Autostart-Konfiguration ein..."
    mkdir -p $HOME/.config/openbox
    cat <<EOF > $HOME/.config/openbox/autostart
# Starte Midori im Kiosk-Modus
midori -a https://localhost -e Fullscreen -e NoMenubar -e NoStatusbar -e NoNavigationbar &
EOF
    log "Openbox und Midori sind eingerichtet."
}

# Funktion zur Erstellung der Webseite und Konfiguration von HTTPS
setup_lighttpd_https() {
    log "Erstelle generische Webseite und richte HTTPS ein..."
    WEB_ROOT="/var/www/html"
    CERT_DIR="/etc/lighttpd/certs"

    sudo mkdir -p $WEB_ROOT
    echo "<?php phpinfo(); ?>" | sudo tee $WEB_ROOT/index.php

    cat <<EOF | sudo tee $WEB_ROOT/index.html
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
EOF

    sudo mkdir -p $CERT_DIR
    sudo openssl req -new -x509 -days 365 -nodes -out $CERT_DIR/lighttpd.pem -keyout $CERT_DIR/lighttpd.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=MyOrg/OU=IT/CN=localhost"
    sudo chmod 600 $CERT_DIR/lighttpd.pem

    cat <<EOF | sudo tee -a /etc/lighttpd/lighttpd.conf

# HTTPS Konfiguration
server.modules += ("mod_openssl")
$SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/lighttpd/certs/lighttpd.pem"
}

# PHP Konfiguration
server.modules += ("mod_fastcgi")
fastcgi.server = ( ".php" =>
    ( "localhost" =>
        (
            "socket" => "/var/run/lighttpd/php.socket",
            "bin-path" => "/usr/bin/php-cgi"
        )
    )
)
EOF

    sudo service lighttpd force-reload
    log "HTTPS und Lighttpd sind konfiguriert."
}

# Liste der zu installierenden Dienste
SERVICES=("SQLite" "Terraform" "Ansible" "git" "Python" "C++ Compiler" "Openbox" "Midori" "Lighttpd")

# Installation der Dienste
for SERVICE in "${SERVICES[@]}"; do
    log "Installiere $SERVICE..."
    install_service "$SERVICE"
done

# Openbox und Midori einrichten
setup_openbox_midori

# Lighttpd und HTTPS einrichten
setup_lighttpd_https

# Lighttpd beim Systemstart aktivieren
log "Aktiviere Lighttpd für den Systemstart..."
sudo systemctl enable lighttpd

# Openbox beim Systemstart aktivieren
log "Aktiviere Openbox für den Systemstart..."
cat <<EOF > $HOME/.xinitrc
exec openbox-session
EOF

log "Installations- und Konfigurationsvorgang abgeschlossen."
