Setting up certificates
-----------------------

Go to registry shared folder and setup CA directory tree:
```
mkdir ca
cd ca
mkdir certs crl newcerts private csrs
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
```

Generate the root key (prompts for pass phrase): 
```
openssl genrsa -aes256 -out private/ca.key.pem 4096
```

Configure OpenSSL:
```
sudo su -
cd /etc/ssl/
cp openssl.cnf openssl.cnf.bak
nano openssl.cnf
exit
```

Make sure the following options are in place:
```
crl_extensions = crl_ext

[ CA_default ]
# Where everything is kept
dir = /home/registry/registry/shared/ca

[ usr_cert ]
# These extensions are added when 'ca' signs a request.
basicConstraints=CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
nsComment = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

[ v3_ca ]
# Extensions for a typical CA
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true
keyUsage = cRLSign, keyCertSign

# For the CA policy
[ policy_match ]
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

Issue the root certificate (prompts for additional data):
```
openssl req -new -x509 -days 3650 -key private/ca.key.pem -sha256 -extensions v3_ca -out certs/ca.crt.pem
chmod 444 certs/ca.crt.pem
```

Create a CSR for the webclient:
```
openssl genrsa -out private/webclient.key.pem 4096
chmod 400 private/webclient.key.pem
openssl req -sha256 -new -key private/webclient.key.pem -out csrs/webclient.csr.pem
```

Sign the request and create certificate:
```
openssl ca -keyfile private/ca.key.pem -cert certs/ca.crt.pem -extensions usr_cert -notext -md sha256 -in csrs/webclient.csr.pem -out certs/webclient.crt.pem
chmod 444 certs/webclient.crt.pem
```

Create certificate revocation list (prompts for pass phrase):
```
openssl ca -keyfile private/ca.key.pem -cert certs/ca.crt.pem -gencrl -out crl/crl.pem
```

Configure EPP virtual host:
```
sudo nano /etc/apache2/sites-enabled/epp.conf
```

Replace this line:
```
SSLVerifyClient optional_no_ca
```

With these lines:
```
  SSLVerifyClient require
  SSLVerifyDepth 1
  SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.crt.pem
  SSLCARevocationFile /home/registry/registry/shared/ca/crl/crl.pem
  # Uncomment this when upgrading to apache 2.4:
  # SSLCARevocationCheck chain
  RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
```

Configure webclient virtual host:
```
sudo nano /etc/apache2/sites-enabled/webclient.conf
```

Add these lines:
```
  SSLVerifyClient none
  SSLVerifyDepth 1
  SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.crt.pem
  SSLCARevocationFile /home/registry/registry/shared/ca/crl/crl.pem
  # Uncomment this when upgrading to apache 2.4:
  # SSLCARevocationCheck chain

  RequestHeader set SSL_CLIENT_S_DN_CN ""

  <Location /login/pki>
    SSLVerifyClient require
  </Location>

  <Location /sessions/pki>
    SSLVerifyClient require
    RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
  </Location> 
```

Reload apache:
```
sudo a2enmod headers
sudo /etc/init.d/apache2 restart
```

Configure registry and epp application.yml to match the CA settings:
```
ca_cert_path: '/home/registry/registry/shared/ca/certs/ca.crt.pem'
ca_key_path: '/home/registry/registry/shared/ca/private/ca.key.pem'
ca_key_password: 'registryalpha'
crl_path: '/home/registry/registry/shared/ca/crl/crl.pem'
webclient_ip: '54.154.91.240'
```

Configure webclient application.yml to match the CA settings:
```
cert_path: '/home/registry/registry/shared/ca/certs/webclient.crt.pem'
key_path: '/home/registry/registry/shared/ca/private/webclient.key.pem'
```

