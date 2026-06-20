#!/usr/bin/env bash
set -e

CA_DIR="$HOME/test-ca"
DOMAIN="ade.test"

mkdir -p "$CA_DIR"/{certs,private,csr,newcerts}
cd "$CA_DIR"

chmod 700 private
touch index.txt
echo 1000 > serial

echo "Criando chave privada da CA..."

openssl genrsa -out private/ca.key 4096
chmod 600 private/ca.key

echo "Criando certificado raiz da CA..."

openssl req -x509 -new -nodes \
  -key private/ca.key \
  -sha256 \
  -days 3650 \
  -out certs/ca.crt \
  -subj "/C=BR/ST=PR/L=Maringa/O=ADE Test/OU=DevOps/CN=ADE Test Root CA"

echo "CA criada com sucesso:"
echo "$CA_DIR/certs/ca.crt"

echo "Criando chave privada do domínio ${DOMAIN}..."

openssl genrsa -out "private/${DOMAIN}.key" 2048
chmod 600 "private/${DOMAIN}.key"

echo "Criando arquivo de configuração do certificado..."

cat > "csr/${DOMAIN}.cnf" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C  = BR
ST = PR
L  = Maringa
O  = ADE Test
OU = DevOps
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = www.${DOMAIN}
EOF

echo "Gerando CSR para ${DOMAIN}..."

openssl req -new \
  -key "private/${DOMAIN}.key" \
  -out "csr/${DOMAIN}.csr" \
  -config "csr/${DOMAIN}.cnf"

echo "Assinando certificado ${DOMAIN} com a CA local..."

openssl x509 -req \
  -in "csr/${DOMAIN}.csr" \
  -CA certs/ca.crt \
  -CAkey private/ca.key \
  -CAcreateserial \
  -out "certs/${DOMAIN}.crt" \
  -days 825 \
  -sha256 \
  -extensions req_ext \
  -extfile "csr/${DOMAIN}.cnf"

echo "Validando certificado gerado..."

openssl verify -CAfile certs/ca.crt "certs/${DOMAIN}.crt"

echo
echo "Arquivos gerados:"
echo "CA pública:        $CA_DIR/certs/ca.crt"
echo "CA privada:        $CA_DIR/private/ca.key"
echo "Certificado TLS:   $CA_DIR/certs/${DOMAIN}.crt"
echo "Chave TLS:         $CA_DIR/private/${DOMAIN}.key"
echo "CSR:               $CA_DIR/csr/${DOMAIN}.csr"