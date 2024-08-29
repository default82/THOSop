#!/bin/bash

# Logdatei anlegen
LOGFILE="/var/log/install_script.log"
> $LOGFILE

# Funktion zum Loggen
log() {
    echo "$1" | tee -a $LOGFILE
}

log "Beginne mit der Installation und Konfiguration..."

# System aktualisieren
log "Aktualisiere System..."
sudo apt-get update && sudo apt-get upgrade -y

# Erforderliche Pakete installieren
log "Installiere erforderliche Pakete..."
sudo apt-get install -y openbox midori lighttpd php-cgi openssl git build-essential

# Openbox konfigurieren und Midori im Kiosk-Modus starten lassen
log "Richte Openbox Autostart-Konfiguration ein..."
mkdir -p $HOME/.config/openbox
cat <<EOF > $HOME/.config/openbox/autostart
# Starte Midori im Kiosk-Modus
midori -a https://localhost -e Fullscreen -e NoMenubar -e NoStatusbar -e NoNavigationbar &
EOF

# PHP mit Lighttpd verbinden
log "Verbinde PHP mit Lighttpd..."
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload

# Erstellen der generischen Webseite
log "Erstelle generische Webseite..."
WEB_ROOT="/var/www/html"
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

# HTTPS einrichten
log "Richte HTTPS ein..."
CERT_DIR="/etc/lighttpd/certs"
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

log "HTTPS und PHP Konfiguration abgeschlossen."

# Lighttpd beim Systemstart aktivieren
log "Aktiviere Lighttpd für den Systemstart..."
sudo systemctl enable lighttpd

# Openbox beim Systemstart aktivieren
log "Aktiviere Openbox für den Systemstart..."
cat <<EOF > $HOME/.xinitrc
exec openbox-session
EOF

log "Installations- und Konfigurationsvorgang abgeschlossen."
