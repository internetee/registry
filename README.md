Domain Registry
===============

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
* [Database diagram](/doc/models_complete.svg)
* [Controllers diagram](/doc/controllers_complete.svg)

### Updating documentation

    AUTODOC=true rspec spec/requests
    EPP_DOC=true rspec spec/epp --tag epp --require support/epp_doc.rb --format EppDoc > doc/epp-examples.md

Installation
------------

### Registry app 

Registry based on Rails 4 installation (rbenv install is under Debian build doc)

Manual demo install and database setup:

    cd /home/registry
    git clone git@github.com:internetee/registry.git demo-registry
    cd demo-registry
    rbenv local 2.2.1
    bundle
    cp config/application-example.yml config/application.yml # and edit it
    cp config/database-example.yml config/database.yml # and edit it
    bundle exec rake db:all:setup # for production, please follow deployment howto
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

  # Rewrite /login to /admin/login
  RewriteEngine on
  RewriteCond %{REQUEST_URI} ^/login [NC]
  RewriteRule ^/(.*) /admin/$1 [PT,L,QSA]

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

  SSLProtocol TLSv1
  SSLHonorCipherOrder On
  SSLCipherSuite RC4-SHA:HIGH:!ADH

	<Directory /app/registry/registry/current/public>
    # for Apache older than version 2.4
    Allow from all

    # for Apache verison 2.4 or newer
    # Require all granted
    
    Options -MultiViews
	</Directory>

  <Location ~ "/.+/" >
    Deny from all
  </Location>

  <Location ~ "/(admin|assets)\/.+">
    Allow from all
  </Location>
</VirtualHost>
```

Registrar configuration (/etc/apache2/sites-enabled/registrar.conf) is as follows: 
```
<VirtualHost *:443>
  ServerName your-registrar-domain
  ServerAdmin your@example.com

  # Rewrite /login to /registrar/login
  RewriteEngine on
  RewriteCond %{REQUEST_URI} ^/login [NC]
  RewriteRule ^/(.*) /registrar/$1 [PT,L,QSA]

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
  ErrorLog /var/log/apache2/registry.error.log
  CustomLog /var/log/apache2/registry.access.log combined
  
  SSLEngine On
  SSLCertificateFile    /etc/ssl/certs/your.crt
  SSLCertificateKeyFile /etc/ssl/private/your.key
  SSLCertificateChainFile /etc/ssl/certs/your-chain-fail.pem
  SSLCACertificateFile /etc/ssl/certs/ca.pem

  SSLProtocol TLSv1
  SSLHonorCipherOrder On
  SSLCipherSuite RC4-SHA:HIGH:!ADH

  <Directory /app/registry/registrar/current/public>
    # comment out if Apache 2.4 or newer
    Allow from all

    # uncomment if Apache 2.4 or newer
    # Require all granted
    
    Options -MultiViews
  </Directory>

  <Location ~ "/.+/" >
    Deny from all
  </Location>

  <Location ~ "/(registrar|assets)\/.+">
    Allow from all
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
  SSLCARevocationFile /home/registry/registry/shared/ca/crl/crl.pem
  SSLCARevocationCheck chain

  RequestHeader set SSL_CLIENT_S_DN_CN ""

  <Location />
    Deny from all
  </Location>

  <Location /repp/*/*>
    Allow from all
    SSLVerifyClient require
    RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"
  </Location>
</VirtualHost>
```

For Apache, epp goes to port 700.  
Be sure to update paths to match your system configuration.  
/etc/apache2/sites-enabled/epp.conf short example:
```apache
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
    SSLCARevocationFile /home/registry/registry/shared/ca/crl/crl.pem
    # Uncomment this when upgrading to apache 2.4:
    # SSLCARevocationCheck chain

    RequestHeader set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"

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
sudo apt-get install libxext-dev libxrender1
```

### Certificates setup

* [Certificates setup](/doc/certificates.md)


### Deployment

* [Application build and update](/doc/application_build_doc.md)


### Autotesting

* [Testing](/doc/testing.md)


### EPP web client

Please follow EPP web client readme:

    https://github.com/internetee/EPP-web-client


### WHOIS server

Please follow WHOIS server readme:

    https://github.com/internetee/whois


## Code Status

Alpha release status, only model tests:
[![Build Status](https://travis-ci.org/domify/registry.svg?branch=master)](https://travis-ci.org/domify/registry)
