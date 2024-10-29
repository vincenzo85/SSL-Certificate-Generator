#!/bin/bash

# Verifica che lo script sia eseguito come root
if [ "$(id -u)" != "0" ]; then
   echo "Questo script deve essere eseguito come root" 1>&2
   exit 1
fi

# Funzione per verificare se un comando esiste
command_exists () {
    command -v "$1" >/dev/null 2>&1 ;
}

# Scelta della lingua
echo "Seleziona la lingua / Select language:"
echo "1) Italiano"
echo "2) English"
read -p "Inserisci la tua scelta / Enter your choice [1-2]: " LANGUAGE

# Funzione per messaggi in base alla lingua scelta
msg() {
    if [ "$LANGUAGE" == "1" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

# Variabili iniziali
CERTS_DIR="$HOME/certs"
CA_KEY="myCA.key"
CA_CERT="myCA.pem"
SERVER_KEY="server.key"
SERVER_CSR="server.csr"
SERVER_CERT="server.crt"
EXT_FILE="server.ext"

# Chiedi all'utente il dominio
if [ "$LANGUAGE" == "1" ]; then
    read -p "Inserisci il nome di dominio (es: esempio.local): " DOMAIN
else
    read -p "Enter the domain name (e.g., example.local): " DOMAIN
fi

# Chiedi all'utente se ha Apache o Nginx
msg "Quale server web stai utilizzando?" "Which web server are you using?"
msg "1) Apache" "1) Apache"
msg "2) Nginx" "2) Nginx"
msg "3) Nessuno/Altro" "3) None/Other"
if [ "$LANGUAGE" == "1" ]; then
    read -p "Seleziona un'opzione [1-3]: " SERVER_CHOICE
else
    read -p "Select an option [1-3]: " SERVER_CHOICE
fi

# Chiedi se desidera che lo script configuri il server
if [ "$LANGUAGE" == "1" ]; then
    read -p "Vuoi che lo script configuri automaticamente il server web? [s/n]: " CONFIGURE_SERVER
else
    read -p "Would you like the script to automatically configure the web server? [y/n]: " CONFIGURE_SERVER
fi

# Installazione dei pacchetti necessari
apt update

if ! command_exists openssl ; then
    apt install -y openssl
fi

if ! command_exists update-ca-certificates ; then
    apt install -y ca-certificates
fi

if [ "$SERVER_CHOICE" == "1" ] && ! command_exists apache2 ; then
    apt install -y apache2
elif [ "$SERVER_CHOICE" == "2" ] && ! command_exists nginx ; then
    apt install -y nginx
fi

# Creazione della directory per i certificati
mkdir -p "$CERTS_DIR"
cd "$CERTS_DIR"

# Generazione della chiave privata per il CA
msg "Generazione della chiave privata per il CA..." "Generating the private key for the CA..."
openssl genrsa -des3 -out "$CA_KEY" 2048

# Generazione del certificato self-signed per il CA
msg "Generazione del certificato self-signed per il CA..." "Generating the self-signed certificate for the CA..."
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 1825 -out "$CA_CERT"

# Copia del certificato CA nella store dei certificati di sistema
msg "Aggiunta del certificato CA alla store dei certificati di sistema..." "Adding the CA certificate to the system's trusted store..."
cp "$CA_CERT" /usr/local/share/ca-certificates/myCA.crt
update-ca-certificates

# Generazione della chiave privata per il server
msg "Generazione della chiave privata per il server..." "Generating the private key for the server..."
openssl genrsa -out "$SERVER_KEY" 2048

# Generazione della CSR per il server
msg "Generazione della CSR per il server..." "Generating the CSR for the server..."
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "/C=IT/ST=/L=/O=/OU=/CN=$DOMAIN/emailAddress="

# Creazione del file delle estensioni
msg "Creazione del file delle estensioni..." "Creating the extensions file..."
cat > "$EXT_FILE" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
EOF

# Generazione del certificato per il server firmato dal CA
msg "Generazione del certificato per il server firmato dal CA..." "Generating the server certificate signed by the CA..."
openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$SERVER_CERT" -days 825 -sha256 -extfile "$EXT_FILE"

# Copia dei certificati nelle directory appropriate
cp "$SERVER_CERT" /etc/ssl/certs/
cp "$SERVER_KEY" /etc/ssl/private/

# Configurazione del server web
if [[ "$CONFIGURE_SERVER" =~ ^[sSyY]$ ]]; then
    if [ "$SERVER_CHOICE" == "1" ]; then
        # Configurazione per Apache
        msg "Configurazione di Apache..." "Configuring Apache..."
        APACHE_CONF="/etc/apache2/sites-available/$DOMAIN.conf"
        cat > "$APACHE_CONF" << EOF
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/$SERVER_CERT
    SSLCertificateKeyFile /etc/ssl/private/$SERVER_KEY

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
        a2enmod ssl
        a2ensite "$DOMAIN.conf"
        systemctl restart apache2
    elif [ "$SERVER_CHOICE" == "2" ]; then
        # Configurazione per Nginx
        msg "Configurazione di Nginx..." "Configuring Nginx..."
        NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
        cat > "$NGINX_CONF" << EOF
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate     /etc/ssl/certs/$SERVER_CERT;
    ssl_certificate_key /etc/ssl/private/$SERVER_KEY;

    root /var/www/html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/
        systemctl restart nginx
    else
        msg "Configurazione automatica del server non supportata per questa opzione." "Automatic server configuration is not supported for this option."
    fi
else
    msg "Configurazione del server web saltata." "Web server configuration skipped."
fi

# Aggiunta del certificato del server alla store dei certificati di sistema
msg "Aggiunta del certificato del server alla store dei certificati di sistema..." "Adding the server certificate to the system's trusted store..."
cp /etc/ssl/certs/"$SERVER_CERT" /usr/local/share/ca-certificates/"$SERVER_CERT"
update-ca-certificates

msg "Operazione completata. Il certificato SSL per $DOMAIN è stato creato." "Operation completed. The SSL certificate for $DOMAIN has been created."
