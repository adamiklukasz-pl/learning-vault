#!/bin/bash

SUBJECT="/C=PL/ST=Malopolskie/L=Cracow/O=Splunk/OU=IT/CN=Vault"

mkdir -p ./.gen_certs
mkdir -p ./vault/certs

currentPath=$(pwd)
certPath=${currentPath}/.gen_certs

# Create CA 
openssl genrsa -out $certPath/ca.key.pem 4096
openssl req -key $certPath/ca.key.pem -new -x509 -days 7300 -sha256 -out $certPath/ca.cert.pem -extensions v3_ca -subj $SUBJECT

cat > "$certPath/server1.conf" <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS = server1
EOF

# Create Vault cert
openssl genrsa -out $certPath/server1.key 4096
openssl req -new -key $certPath/server1.key -out $certPath/server1.csr -subj "/CN=server1/O=server1" -config "$certPath/server1.conf"
openssl x509 -req -days 180 -CA $certPath/ca.cert.pem -CAkey $certPath/ca.key.pem -CAcreateserial -in $certPath/server1.csr -out $certPath/server1.pem

# Copy certs to vault directory
vaultCerts=$currentPath/vault/certs
cp $certPath/server1.key $vaultCerts/vault_key.key
cp $certPath/server1.pem $vaultCerts/vault_cert.pem
cat $certPath/ca.cert.pem >> $vaultCerts/vault_cert.pem

chmod 0755 $vaultCerts/*
