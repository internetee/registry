Certificates setup
------------------

Guide to setup all registry/epp/repp, webclient and api user certificates.

There are three type of certificates:

* root cert (one time action using command line)
* webclient server cert (one time action using command line)
* api user cert (multiple actions through admin interface)

API users CSR are uploaded through registry admin interface for each API user.

Private key and certificate must be packaged to pkcs12 and added to user browser.


### Registry setup

Configure OpenSSL:

    sudo cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.bak
    sudo vi /etc/ssl/openssl.cnf

Make sure the following options are in place:

    [ CA_default ]
    # Where everything is kept
    dir = /home/registry/registry/shared/ca                       # around line nr 42

    crl_extensions = crl_ext                                      # around line nr 71

    # For the CA policy
    [ policy_match ]
    countryName             = optional                            # around line nr 85
    stateOrProvinceName     = optional                            # around line nr 86
    organizationName        = optional                            # around line nr 87
    organizationalUnitName  = optional                            # around line nr 88
    commonName              = supplied                            # around line nr 89
    emailAddress            = optional                            # around line nr 90

    [ usr_cert ]
    # These extensions are added when 'ca' signs a request.
    basicConstraints=CA:FALSE                                     # around line nr 170
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment  # around line nr 188
    nsComment = "OpenSSL Generated Certificate"                   # around line nr 191
    subjectKeyIdentifier=hash                                     # around line nr 194
    authorityKeyIdentifier=keyid,issuer                           # around line nr 195

    [ v3_ca ]
    # Extensions for a typical CA
    subjectKeyIdentifier=hash                                     # around line nr 232
    authorityKeyIdentifier=keyid:always,issuer                    # around line nr 234
    basicConstraints = CA:true                                    # around line nr 240
    keyUsage = cRLSign, keyCertSign                               # around line nr 245

Setup CA directory in shared directory:

    cd /home/registry/registry/shared
    mkdir ca ca/certs ca/crl ca/newcerts ca/private ca/csrs
    cd ca
    chmod 700 private
    touch index.txt
    echo 1000 > serial
    echo 1000 > crlnumber

Generate the root key and remember your password, you need it later in application.yml: 

    openssl genrsa -aes256 -out private/ca.key.pem 4096

Create root registry certificate (prompts for additional data and review days flag):

    openssl req -new -x509 -days 3653 -key private/ca.key.pem -sha256 -extensions v3_ca -out certs/ca.crt.pem
    chmod 444 certs/ca.crt.pem

Create a webclient key and CSR for accepting webclient request:

    openssl genrsa -out private/webclient.key.pem 4096
    chmod 400 private/webclient.key.pem
    openssl req -sha256 -new -days 3653 -key private/webclient.key.pem -out csrs/webclient.csr.pem

Sign CSR and create certificate:

    openssl ca -keyfile private/ca.key.pem -cert certs/ca.crt.pem -extensions usr_cert -notext -md sha256 -in csrs/webclient.csr.pem -days 3653 -out certs/webclient.crt.pem
    chmod 444 certs/webclient.crt.pem

Create certificate revocation list (prompts for pass phrase):

    openssl ca -keyfile private/ca.key.pem -cert certs/ca.crt.pem -gencrl -out crl/crl.pem

Configure registry registry/shared/config/application.yml to match the CA settings:

    crl_path:     '/home/registry/registry/shared/ca/crl/crl.pem'
    ca_cert_path: '/home/registry/registry/shared/ca/certs/ca.crt.pem'
    ca_key_path:  '/home/registry/registry/shared/ca/private/ca.key.pem'
    ca_key_password: 'your-root-key-password'


### Registry EPP setup

Configure registry epp registry-epp/shared/config/application.yml:

    webclient_ip: '54.154.91.240'

Configure EPP port 700 virtual host:

    sudo vi /etc/apache2/sites-enabled/epp.conf

Replace this line:

    SSLVerifyClient optional_no_ca

With these lines:

    SSLVerifyClient require
    SSLVerifyDepth 1
    SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.crt.pem
    SSLCARevocationFile /home/registry/registry/shared/ca/crl/crl.pem
    # Uncomment this when upgrading to apache 2.4:
    # SSLCARevocationCheck chain
    RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"

Reload apache:

    sudo a2enmod headers
    sudo /etc/init.d/apache2 restart


### Webclient setup

Copy all registry/shared/ca directory to your webclient server if webclient is in different server,
otherwise just point everything to your registry/shared/ca directory.

Configure webclient/shared/config/application.yml to match the CA settings:

    cert_path: '/home/webclient/webclient/shared/ca/certs/webclient.crt.pem'
    key_path:  '/home/webclient/webclient/shared/ca/private/webclient.key.pem'

Configure webclient virtual host:

    sudo vi /etc/apache2/sites-enabled/webclient.conf

Add these lines:

    SSLVerifyClient none
    SSLVerifyDepth 1
    SSLCACertificateFile /home/webclient/webclient/shared/ca/certs/ca.crt.pem
    SSLCARevocationFile  /home/webclient/webclient/shared/ca/crl/crl.pem
    # Uncomment this when upgrading to apache 2.4:
    # SSLCARevocationCheck chain

    RequestHeader set SSL_CLIENT_S_DN_CN ""

    <Location /sessions/pki>
      SSLVerifyClient require
      RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
    </Location> 

Reload apache:

    sudo a2enmod headers
    sudo /etc/init.d/apache2 restart


Development env
---------------

In development environment it's convenient to set unique_subject option to false,
thus you can generate quickly as many certs as you wish.

In CA directory:

    echo "unique_subject = no" > index.txt.attr
