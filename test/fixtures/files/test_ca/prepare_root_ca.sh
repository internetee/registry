# Prepare required files
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# Generate Root CA.
openssl genrsa -aes256 -out private/ca.key.pem 4096
openssl req -config openssl.cnf -new -x509 -days 365 -key private/ca.key.pem -sha256 -extensions v3_ca -out certs/ca.crt.pem
