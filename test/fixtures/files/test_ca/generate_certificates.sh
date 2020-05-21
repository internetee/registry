# !/bin/sh
# Use localhost as common name.
openssl genrsa -out private/client.key.pem 4096
openssl req -sha256 -config openssl.cnf -new -days 3650 -key private/client.key.pem -out csrs/client.csr.pem
openssl ca -config openssl.cnf -keyfile private/ca.key.pem -cert certs/ca.crt.pem -extensions usr_cert -notext -md sha256 -in csrs/client.csr.pem -days 3650 -out certs/client.crt.pem

openssl genrsa -out private/revoked.key.pem 4096
openssl req -sha256 -config openssl.cnf -new -days 3650 -key private/revoked.key.pem -out csrs/revoked.csr.pem
openssl ca -config openssl.cnf -keyfile private/ca.key.pem -cert certs/ca.crt.pem -extensions usr_cert -notext -md sha256 -in csrs/revoked.csr.pem -days 3650 -out certs/revoked.crt.pem
openssl ca -config openssl.cnf -keyfile private/ca.key.pem -cert certs/ca.crt.pem -revoke certs/revoked.crt.pem

openssl ca -config openssl.cnf -keyfile private/ca.key.pem -cert certs/ca.crt.pem -crldays 3650 -gencrl -out crl/crl.pem

openssl req -config openssl.cnf -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout private/apache.key -config server.csr.cnf
openssl x509 -req -in server.csr -CA certs/ca.crt.pem  -CAkey private/ca.key.pem -CAcreateserial -out certs/apache.crt -days 3650 -sha256 -extfile v3.ext
