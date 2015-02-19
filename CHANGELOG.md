19.02.2015
 
Go to registry shared folder and setup CA directory tree:
```
mkdir ca
cd ca
mkdir certs crl newcerts private csrs
chmod 700 private
touch index.txt
echo 1000 > serial
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
openssl req -new -x509 -days 3650 -key private/ca.key.pem -sha256 -extensions v3_ca -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem
```

Create a CSR for the webclient:
```
openssl genrsa -out private/webclient.key.pem 4096
chmod 400 private/webclient.key.pem
openssl req -sha256 -new -key private/webclient.key.pem -out csrs/webclient.csr.pem
```

Sign the request and create certificate:
```
openssl ca -keyfile private/ca.key.pem -cert certs/ca.cert.pem -extensions usr_cert -notext -md sha256 -in csrs/webclient.csr.pem -out certs/webclient.cert.pem
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
  SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.cert.pem
  RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
```

Configure webclient virtual host:
```
  SSLVerifyClient none
  SSLVerifyDepth 1
  SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.cert.pem

  RequestHeader set SSL_CLIENT_S_DN_CN ""

  <Location /login/pki>
    SSLVerifyClient require
  </Location>

  <Location /sessions>
    SSLVerifyClient require
    RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
  </Location> 
```

Reload apache:
```
sudo a2enmod headers
sudo /etc/init.d/apache2 reload
```

Configure application.yml to match the CA settings:
```
ca_cert_path: '/home/registry/registry/shared/ca/certs/ca.cert.pem'
ca_key_path: '/home/registry/registry/shared/ca/private/ca.key.pem'
ca_key_password: 'registryalpha'
```

20.01.2015

* Added dedicated mina cron:setup and mina cron:clear for manual cron management.
  Automatic management during deploy removed.
* Added mina config for epp: "mina eppst deploy" and "mina epppr deploy" 

19.01.2015

* Added application-exapmle.yml and removed application.yml from repo, please 
  add config/application.yml back when deploying:
  cp current/config/application-example.yml shared/config/application.yml # and edit it
* Removed config/initilizers/devise_secret.rb, use application.yml

16.01.2015

* Added new rake tasks: rake db:all:setup to setup all databases
  Find out more tasks for all databases with rake -T db:all

* Staging env added, please change apache conf in staging servers to "RailsEnv staging"
  Then you need to add or update staging section in
  --> config/database.yml
  --> config/secrets.yml
  --> config/application.yml

15.01.2015

* Registry api log and whois database added, please update your database.yml,
  you can view updated config at config/database-example.yml
* Upgraded to Rails 4.2 and ruby 2.2.0, be sure you have ruby 2.2.0 in your rbenv 
  NB! Update you passenger deb install, it should have recent fix for ruby 2.2.0

14.01.2015

* Update your Apache EPP conf file, add "EPPRawFrame raw_frame", inspect example file at Readme
  Otherwise new master EPP will not work.
