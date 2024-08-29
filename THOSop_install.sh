#!/bin/bash

# Protokolldatei festlegen und löschen
LOGFILE="/var/log/thosop_install.log"
> "$LOGFILE"

# Alle Ausgaben in die Protokolldatei umleiten, nur Statusmeldungen werden angezeigt
exec 3>&1 1>>"$LOGFILE" 2>&1

# Funktion zum Loggen
log() {
    echo "$1" >&3
}

log "Beginne mit der Installation und Konfiguration..."

# Systemaktualisierung
log "Aktualisiere System..."
sudo apt-get update
sudo apt-get upgrade -y

# Installiere erforderliche Pakete
log "Installiere erforderliche Pakete..."
sudo apt-get install -y sqlite3 libsqlite3-dev ansible git python3 python3-pip g++ openbox lighttpd php-cgi openssl

# Midori Installation und Fallback auf Chromium, wenn Midori nicht verfügbar ist
if ! command -v midori &> /dev/null; then
    log "Midori nicht verfügbar. Installiere stattdessen Chromium..."
    sudo apt-get install -y chromium-browser
fi

# Openbox Autostart-Konfiguration
log "Richte Openbox Autostart-Konfiguration ein..."
mkdir -p ~/.config/openbox
echo "chromium-browser --kiosk http://localhost" > ~/.config/openbox/autostart

# Lighttpd und PHP konfigurieren
log "Verbinde PHP mit Lighttpd..."
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php

log "Richte HTTPS ein..."
sudo mkdir -p /etc/lighttpd/certs
sudo openssl req -new -x509 -keyout /etc/lighttpd/certs/lighttpd.pem -out /etc/lighttpd/certs/lighttpd.pem -days 365 -nodes -subj "/C=DE/ST=Berlin/L=Berlin/O=Example/OU=IT/CN=example.com"

# Lighttpd Konfiguration für HTTPS
sudo bash -c 'cat <<EOF > /etc/lighttpd/lighttpd.conf
server.modules += ("mod_openssl")
$SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/lighttpd/certs/lighttpd.pem"
}
server.modules += ("mod_fastcgi")
fastcgi.server = ( ".php" =>
    ( "localhost" =>
        (
            "socket" => "/var/run/lighttpd/php.socket",
            "bin-path" => "/usr/bin/php-cgi"
        )
    )
)
EOF'

sudo systemctl restart lighttpd

# Autostart für Openbox und Lighttpd
log "Aktiviere Lighttpd für den Systemstart..."
sudo systemctl enable lighttpd

log "Aktiviere Openbox für den Systemstart..."
echo "exec openbox-session" > ~/.xinitrc

log "Installations- und Konfigurationsvorgang abgeschlossen."
