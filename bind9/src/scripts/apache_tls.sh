#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

SERVER_NAME="server1.ade.test"
WEB_DIR="/var/www/html"

TLS_DIR="/etc/ssl/ade"
TLS_CERT="${TLS_DIR}/${SERVER_NAME}.crt"
TLS_KEY="${TLS_DIR}/${SERVER_NAME}.key"
TLS_CA="${TLS_DIR}/ca.crt"

apt-get update
apt-get install -y \
    apache2 \
    vim \
    dnsutils

rm -rf "$WEB_DIR"/*

cat <<EOF > "$WEB_DIR/index.html"
<h1>Servidor 1 com TLS CA própria</h1>
EOF

# Garante diretório para receber os certificados
mkdir -p "$TLS_DIR"

# Valida se os certificados já existem
if [ ! -f "$TLS_CERT" ]; then
    echo "ERRO: certificado não encontrado: $TLS_CERT"
    exit 1
fi

if [ ! -f "$TLS_KEY" ]; then
    echo "ERRO: chave privada não encontrada: $TLS_KEY"
    exit 1
fi

# Opcional, mas recomendado se você quiser manter a cadeia da CA no servidor
if [ ! -f "$TLS_CA" ]; then
    echo "AVISO: CA não encontrada: $TLS_CA"
fi

chmod 644 "$TLS_CERT"
chmod 600 "$TLS_KEY"

# Habilita TLS no Apache
a2enmod ssl
a2enmod headers

# VirtualHost HTTP redirecionando para HTTPS
cat <<EOF > /etc/apache2/sites-available/server1-http.conf
<VirtualHost *:80>
    ServerName ${SERVER_NAME}
    Redirect permanent / https://${SERVER_NAME}/
</VirtualHost>
EOF

# VirtualHost HTTPS
cat <<EOF > /etc/apache2/sites-available/server1-ssl.conf
<VirtualHost *:443>
    ServerName ${SERVER_NAME}
    DocumentRoot ${WEB_DIR}

    SSLEngine on
    SSLCertificateFile ${TLS_CERT}
    SSLCertificateKeyFile ${TLS_KEY}

    <Directory ${WEB_DIR}>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    Header always set Strict-Transport-Security "max-age=31536000"

    ErrorLog \${APACHE_LOG_DIR}/server1-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/server1-ssl-access.log combined
</VirtualHost>
EOF

# Habilita os sites
a2dissite 000-default.conf || true
a2ensite server1-http.conf
a2ensite server1-ssl.conf

apache2ctl configtest
systemctl restart apache2

echo "Apache configurado com TLS."
echo "URL: https://${SERVER_NAME}"
echo "Certificado usado: ${TLS_CERT}"
echo "Chave usada: ${TLS_KEY}"


####

# sudo mkdir -p /etc/ssl/ade

# sudo cp server1.ade.test.crt /etc/ssl/ade/
# sudo cp server1.ade.test.key /etc/ssl/ade/
# sudo cp ca.crt /etc/ssl/ade/