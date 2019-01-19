Domain Registry
===============
[![Build Status](https://travis-ci.org/internetee/registry.svg?branch=master)](https://travis-ci.org/internetee/registry)
[![Maintainability](https://api.codeclimate.com/v1/badges/a91e4ae502a6c5245160/maintainability)](https://codeclimate.com/github/internetee/registry/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a91e4ae502a6c5245160/test_coverage)](https://codeclimate.com/github/internetee/registry/test_coverage)
[![Documentation Status](https://readthedocs.org/projects/eeregistry/badge/?version=latest)](http://docs.internet.ee/en/latest/?badge=latest)

Full stack top-level domain (TLD) management.

* [Documentation](#documentation)
* [Installation](#installation)
* [Deployment](#deployment)
* [Autotesting](#autotesting)


Documentation
-------------

* [EPP documentation](/doc/epp)
* [EPP request-response examples](/doc/epp-examples.md)
* [REPP documentation](/doc/repp-doc.md)

### Updating documentation

    AUTODOC=true rspec spec/requests
    EPP_DOC=true rspec spec/epp --tag epp --require support/epp_doc.rb --format EppDoc > doc/epp_examples.md

Installation
------------

### Registry app

Registry based on Rails 4 installation (rbenv install is under Debian build doc)

Manual demo install and database setup:

    cd /home/registry
    git clone git@github.com:internetee/registry.git demo-registry
    cd demo-registry
    rbenv local 2.2.2
    bundle
    cp config/application.yml.sample config/application.yml # and edit it
    cp config/database.yml.sample config/database.yml # and edit it
    bundle exec rake db:setup:all # for production, please follow deployment howto
    bundle exec rake bootstrap
    bundle exec rake assets:precompile

### Apache with patched mod_epp (Debian 7/Ubuntu 14.04 LTS)

    sudo apt-get install apache2

    sudo apt-get install apache2-threaded-dev     # needed to compile mod_epp
    wget sourceforge.net/projects/aepps/files/mod_epp/1.10/mod_epp-1.10.tar.gz
    tar -xzvf mod_epp-1.10.tar.gz
    cd mod_epp-1.10

Patch mod_epp for Rack. Beacause Rack multipart parser expects specifically
formatted content boundaries, the mod_epp needs to be modified before building:

    wget https://github.com/internetee/registry/raw/master/doc/patches/mod_epp_1.10-rack-friendly.patch
    wget https://raw.githubusercontent.com/domify/registry/master/doc/patches/mod_epp_1.10-frame-size.patch
    patch < mod_epp_1.10-rack-friendly.patch
    patch < mod_epp_1.10-frame-size.patch
    sudo apxs2 -a -c -i mod_epp.c

Enable ssl:

    sudo a2enmod proxy_http
    sudo mkdir /etc/apache2/ssl
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
    sudo a2enmod ssl
    sudo nano /etc/apache2/sites-enabled/epp_ssl.conf

For Apache, registry admin goes to port 443 in production, /etc/apache2/sites-enabled/registry.conf short example:

```
<VirtualHost *:443>
  ServerName your-domain
  ServerAdmin your@example.com

  PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
  PassengerRuby /home/registry/.rbenv/shims/ruby
  PassengerEnabled on
  PassengerMinInstances 10
  PassengerMaxPoolSize 10
  PassengerPoolIdleTime 0
  PassengerMaxRequests 1000

  RailsEnv production # or staging
  DocumentRoot /home/registry/registry/current/public

  # Possible values include: debug, info, notice, warn, error, crit,
  LogLevel info
  ErrorLog /var/log/apache2/registry.error.log
  CustomLog /var/log/apache2/registry.access.log combined

  SSLEngine On
  SSLCertificateFile    /etc/ssl/certs/your.crt
  SSLCertificateKeyFile /etc/ssl/private/your.key
  SSLCertificateChainFile /etc/ssl/certs/your-chain-fail.pem
  SSLCACertificateFile /etc/ssl/certs/ca.pem

  SSLProtocol -all +TLSv1.2
  SSLHonorCipherOrder On
  SSLCompression off
  SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH

  RewriteEnginriteEngine on
  RedirectMatch ^/$ /admin
  RedirectMatch ^/login$ /admin/login

  <Directory /app/registry/registry/current/public>
      # for Apache older than version 2.4
      Allow from all

      # for Apache verison 2.4 or newer
      # Require all granted
      Options -MultiViews
  </Directory>

  <Location />
      Allow from none
      Deny from all
  </Location>

  <Location /admin>
      Allow from all
  </Location>

  <Location /assets>
      Allow from all
  </Location>
</VirtualHost>
```

Registrar configuration (/etc/apache2/sites-enabled/registrar.conf) is as follows:
```
<VirtualHost *:443>
  ServerName your-registrar-domain
  ServerAdmin your@example.com

  PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
  PassengerRuby /home/registry/.rbenv/shims/ruby
  PassengerEnabled on
  PassengerMinInstances 10
  PassengerMaxPoolSize 10
  PassengerPoolIdleTime 0
  PassengerMaxRequests 1000

  RailsEnv production # or staging
  DocumentRoot /home/registry/registrar/current/public

  # Possible values include: debug, info, notice, warn, error, crit,
  LogLevel info
  ErrorLog /var/log/apache2/registrar.error.log
  CustomLog /var/log/apache2/registrar.access.log combined

  SSLEngine On
  SSLCertificateFile    /etc/ssl/certs/your.crt
  SSLCertificateKeyFile /etc/ssl/private/your.key
  SSLCertificateChainFile /etc/ssl/certs/your-chain-fail.pem
  SSLCACertificateFile /etc/ssl/certs/ca.pem

  SSLProtocol -all +TLSv1.2
  SSLHonorCipherOrder On
  SSLCompression off
  SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH

  RewriteEngine on
  RedirectMatch ^/$ /registrar
  RedirectMatch ^/login$ /registrar/login

  <Directory /app/registry/registrar/current/public>
      # for Apache older than version 2.4
      Allow from all

      # for Apache verison 2.4 or newer
      # Require all granted

      Options -MultiViews
  </Directory>

  <Location />
      Allow from none
      Deny from all
  </Location>

  <Location /registrar>
      Allow from all
  </Location>

  <Location /assets>
      Allow from all
  </Location>

  SSLVerifyClient none
  SSLVerifyDepth 1
  SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.cert.pem
  SSLCARevocationPath /home/registry/registry/shared/ca/crl
  # Uncomment in Apache 2.4
  # SSLCARevocationCheck chain

  RequestHeader set SSL_CLIENT_S_DN_CN ""
  RequestHeader set SSL_CLIENT_CERT ""
  <Location /registrar/sessions>
      SSLVerifyClient require
      RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
      RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s"
  </Location>

  <Location /registrar/id>
      SSLVerifyClient require
      Options Indexes FollowSymLinks MultiViews
      SSLVerifyDepth 2
      SSLOptions +StdEnvVars +ExportCertData
  </Location>
</VirtualHost>
```

Registrant configuration (/etc/apache2/sites-enabled/registrant.conf) is as follows:
```
<VirtualHost *:443>
    ServerName your-registrant-domain
    ServerAdmin your@example.com

    PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
    PassengerRuby /home/registry/.rbenv/shims/ruby
    PassengerEnabled on
    PassengerMinInstances 10
    PassengerMaxPoolSize 10
    PassengerPoolIdleTime 0
    PassengerMaxRequests 1000

    RailsEnv production # or staging
    DocumentRoot /home/registry/registrant/current/public

    # Possible values include: debug, info, notice, warn, error, crit,
    LogLevel info
    ErrorLog /var/log/apache2/registrant.error.log
    CustomLog /var/log/apache2/registrant.access.log combined

    SSLEngine On
    SSLCertificateFile    /etc/ssl/certs/your.crt
    SSLCertificateKeyFile /etc/ssl/private/your.key
    SSLCertificateChainFile /etc/ssl/certs/your-chain-fail.pem
    SSLCACertificateFile /etc/ssl/certs/ca.pem

    SSLProtocol -all +TLSv1.2
    SSLHonorCipherOrder On
    SSLCompression off
    SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH

    RewriteEngine on
    RedirectMatch ^/$ /registrant
    RedirectMatch ^/login$ /registrant/login

    <Directory /app/registry/registrant/current/public>
        # for Apache older than version 2.4
        Allow from all

        # for Apache verison 2.4 or newer
        # Require all granted

        Options -MultiViews
    </Directory>

    <Location />
        Allow from none
        Deny from all
    </Location>

    <Location /registrant>
        Allow from all
    </Location>

    <Location /assets>
        Allow from all
    </Location>

    SSLVerifyClient none
    SSLVerifyDepth 1
    SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.cert.pem
    SSLCARevocationPath /home/registry/registry/shared/ca/crl
    # Uncomment in Apache 2.4
    # SSLCARevocationCheck chain

    RequestHeader set SSL_CLIENT_S_DN_CN ""
    RequestHeader set SSL_CLIENT_CERT ""
    <Location /registrant/sessions>
        SSLVerifyClient require
        RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
        RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s"
    </Location>

    <Location /registrant/id>
        SSLVerifyClient require
        Options Indexes FollowSymLinks MultiViews
        SSLVerifyDepth 2
        SSLOptions +StdEnvVars +ExportCertData
    </Location>
</VirtualHost>
```

For Apache, REPP goes to port 443 in production, /etc/apache2/sites-enabled/repp.conf short example:
```
<VirtualHost *:443>
    ServerName your-repp-domain
    SSLEngine on
    #SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    ProxyPreserveHost on
    RequestHeader set X_FORWARDED_PROTO 'https'

    SSLVerifyClient none
    SSLVerifyDepth 1
    SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.crt.pem
    SSLCARevocationPath /home/registry/registry/shared/ca/crl
    # Uncomment this when upgrading to apache 2.4:
    # SSLCARevocationCheck chain

    RequestHeader set SSL_CLIENT_S_DN_CN ""
    RequestHeader set SSL_CLIENT_CERT ""

    <Location />
        Allow from none
        Deny from all
    </Location>

    <Location /repp>
        Allow from all
        SSLVerifyClient require
        RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
        RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s"
    </Location>
</VirtualHost>
```

For Apache, epp goes to port 700.
Be sure to update paths to match your system configuration.
/etc/apache2/sites-enabled/epp.conf short example:
```apache
<IfModule mod_ssl.c>
    Listen 127.0.0.1:8080
    <VirtualHost 127.0.0.1:8080>
        ServerName your-epp-backend-domain
        ServerAdmin your@example.com

        PassengerEnabled on
        PassengerMinInstances 10
        PassengerMaxPoolSize 10
        PassengerPoolIdleTime 0
        PassengerMaxRequests 1000
        PassengerRoot "/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini"
        PassengerRuby "/home/registry/.rbenv/shims/ruby"

        RailsEnv production # or staging
        DocumentRoot "/home/registry/registry/public"

        # Possible values include: debug, info, notice, warn, error, crit,
        LogLevel info
        ErrorLog "/var/log/apache2/eppback.error.log"
        CustomLog "/var/log/apache2/eppback.access.log" combined

        <Directory />
            Options +FollowSymLinks -Indexes
            AllowOverride None
        </Directory>

        <Directory /home/registry/registry/public>
            Order allow,deny
            Allow from all
            Options -MultiViews -Indexes
            AllowOverride all
        </Directory>
    </VirtualHost>
</IfModule>

<IfModule mod_epp.c>
    Listen 700
    <VirtualHost *:700>
      SSLEngine on
      SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
      SSLCertificateFile /etc/apache2/ssl/apache.crt
      SSLCertificateKeyFile /etc/apache2/ssl/apache.key

      SSLVerifyClient require
      SSLVerifyDepth 1
      SSLCACertificateFile /home/registry/registry/shared/ca/certs/ca.crt.pem
      SSLCARevocationPath /home/registry/registry/shared/ca/crl
      # Uncomment this when upgrading to apache 2.4:
      # SSLCARevocationCheck chain

      RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
      RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s"

      EPPEngine On
      EPPCommandRoot          /proxy/command
      EPPSessionRoot          /proxy/session
      EPPErrorRoot            /proxy/error
      EPPRawFrame             raw_frame

      ProxyPass /proxy/ http://localhost:8080/epp/

      EPPAuthURI              implicit
      EPPReturncodeHeader     X-EPP-Returncode
    </VirtualHost>
</IfModule>
```

Enable epp_ssl and restart apache

    sudo a2ensite epp_ssl
    sudo service apache2 restart

Now you should see registry admin at https://your-domain

All registry demo data can be found at:

    db/seeds.rb

Initially you can use two type of users: admin users and EPP users.

### Wkhtmltopdf setup

```
sudo apt-get install libxext-dev libxrender1 fontconfig
```

### Certificates setup

* [Certificates setup](/doc/certificates.md)


### Deployment

* [Application build and update](/doc/application_build_doc.md)
* [Registry que server](/doc/que/README.md)

### Autotesting

* [Testing](/doc/testing.md)

###  Travis CI

* Travis is configured to build against master and staging branches by default.
* Notification emails are sent to committer by default.

### EPP web client

Please follow EPP web client readme:

    https://github.com/internetee/EPP-web-client


### WHOIS server

Please follow WHOIS server readme:

    https://github.com/internetee/whois
