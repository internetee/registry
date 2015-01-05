Domain Registry
===============

Full stack top-level domain (TLD) management.

* [Documentation](https://github.com/internetee/registry#documentation)
* [Installation](https://github.com/internetee/registry#installation)
* [Deployment](https://github.com/internetee/registry#deployment)
* [Staging deployment](https://github.com/internetee/registry#staging-deployment)
* [Autotesting](https://github.com/internetee/registry#autotesting)


Documentation
-------------

* [EPP request-response examples](https://github.com/internetee/registry/blob/master/doc/epp-doc.md)
* [Database diagram](https://github.com/internetee/registry/blob/master/doc/models_complete.svg)
* [Controllers diagram](https://github.com/internetee/registry/blob/master/doc/controllers_complete.svg)


Installation
------------

### Registry app 

Usual Rails 4 app installation (rbenv install is under Debian build doc)

Manual demo install and database setup:

    cd /home/registry
    git clone git@github.com:internetee/registry.git demo-registry
    cd demo-registry
    rbenv local 2.1.2
    bundle
    cp config/database-example.yml config/database.yml # and edit it
    cp config/secrets-example.yml config/secrets.yml # and edit it, generate key with 'rake secret'
    cp config/initializers/devise_secret_example.rb.txt config/initializers/devise_secret.rb # and edit
    bundle exec rake assets:precompile

Create database manually, example: 
    
    create database registry owner registry encoding 'UTF-8' LC_COLLATE 'et_EE.utf8' LC_CTYPE 'et_EE.utf8' template template0;
    rake db:schema:load
    rake db:seeds

Production install (database schema should be loaded and seeds should be present)

    # at your local machine
    git clone git@github.com:internetee/registry.git
    cd registry
    rbenv local 2.1.2 # more info about rbenv at debian doc
    gem install mina
    mina pr setup # one time, only creates missing directories
    ssh registry

    # at your server
    cd registry
    cp current/config/database-example.yml shared/config/database.yml # and edit it
    # You can generate secret keys with 'bundle exec rake secret'
    cp current/config/secrets-example.yml shared/config/secrets.yml # and edit it
    cp current/config/initializers/devise_secret_example.rb.txt shared/config/initializers/devise_secret.rb # and edit it

    vi /etc/apache2/sites-enabled/registry.conf # add conf and all needed serts
    vi /etc/apache2/sites-enabled/epp.conf # add epp conf, restart apache
    exit
    # at your local machine
    mina pr deploy # this is command you use in every application code update

### Apache with patched mod_epp (Debian 7/Ubuntu 14.04 LTS)

    sudo apt-get install apache2

    sudo apt-get install apache2-threaded-dev     # needed to compile mod_epp
    wget sourceforge.net/projects/aepps/files/mod_epp/1.10/mod_epp-1.10.tar.gz
    tar -xzvf mod_epp-1.10.tar.gz
    cd mod_epp-1.10

Patch mod_epp for Rack. Beacause Rack multipart parser expects specifically 
formatted content boundaries, the mod_epp needs to be modified before building:

    wget https://github.com/internetee/registry/raw/master/doc/patches/mod_epp_1.10-rack-friendly.patch    
    patch < mod_epp_1.10-rack-friendly.patch
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

  RailsEnv production
  DocumentRoot /home/registry/registry/current/public
  
	# Possible values include: debug, info, notice, warn, error, crit,
  LogLevel info ssl:warn
  ErrorLog /var/log/apache2/registry.error.log
  CustomLog /var/log/apache2/registry.access.log combined
  
  <Directory /home/registry/registry/current/public>
    Require all granted
    Options -MultiViews
  </Directory>

  SSLEngine On
  SSLCertificateFile    /etc/ssl/certs/your.crt
  SSLCertificateKeyFile /etc/ssl/private/your.key
  SSLCertificateChainFile /etc/ssl/certs/your-chain-fail.pem
  SSLCACertificateFile /etc/ssl/certs/ca.pem

  SSLProtocol TLSv1
  SSLHonorCipherOrder On
  SSLCipherSuite RC4-SHA:HIGH:!ADH

	<Directory />
		Options FollowSymLinks -Indexes
		AllowOverride None
	</Directory>
	<Directory /app/registry/registry/current/public>
		Options -MultiViews -Indexes
		AllowOverride all
	</Directory>
</VirtualHost>
```

For Apache, epp goes to port 700, /etc/apache2/sites-enabled/epp.conf short example:
```apache
<IfModule mod_epp.c>
  Listen 700
  <VirtualHost *:700>
    SSLEngine on
    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    SSLVerifyClient optional_no_ca

    EPPEngine On
    EPPCommandRoot          /proxy/command
    EPPSessionRoot          /proxy/session
    EPPErrorRoot            /proxy/error
    
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


### EPP web client

Please follow EPP web client readme:

    https://github.com/internetee/EPP-web-client


### WHOIS server

Please follow WHOIS server readme:

    https://github.com/internetee/whois


Deployment
----------

* [Debian build](https://github.com/internetee/registry/blob/master/doc/debian_build_doc.md)
* [Application build and update](https://github.com/internetee/registry/blob/master/doc/application_build_doc.md)

CRON
----

Crontab is automatically updated after each deploy. Jobs can be viewed [here](https://github.com/internetee/registry/blob/master/config/schedule.rb).  

Alternatively you can run `mina pr whenever:update` to update the crontab.

Autotesting
-----------

* Before running tests for the first time: `RAILS_ENV=test rake db:seed`
* Run tests: `rake`
* Run EPP tests: `rake test:epp`
* Run all but EPP tests: `rake test:other`

To see internal errors while testing EPP
    
    unicorn -E test -p 8989
    rake spec:epp

### Apache mod_epp autotesting/debugging

Autotesting Apache mod_epp without Registry app.

    sudo apt-get install apache2-dbg 

Includes htpasswd command to generate authentication files

    sudo apt-get install apache2-utils

For manual debugging purposes, standalone CGI scripts can be used:  
This needs a static greeting file, so you will have to make /var/www writable.

```apache
<IfModule mod_epp.c>
    <Directory "/usr/lib/cgi-bin/epp">
        Options ExecCGI
        SetHandler cgi-script
    </Directory>

    Listen 1700

    <VirtualHost *:1700>
        EPPEngine On
        EPPCommandRoot          /cgi-bin/epp/command
        EPPSessionRoot          /cgi-bin/epp/session
        EPPErrorRoot            /cgi-bin/epp/error

        Alias /cgi-bin/epp/session/hello /var/www/html/epp/session-hello

        Alias /cgi-bin/epp/session/login /usr/lib/cgi-bin/epp/session-login
        Alias /cgi-bin/epp/session/logout /usr/lib/cgi-bin/epp/session-logout
        Alias /cgi-bin/epp/error/schema /usr/lib/cgi-bin/epp/error-schema
        Alias /cgi-bin/epp/command/create /usr/lib/cgi-bin/epp/create
        Alias /cgi-bin/epp/command/info /usr/lib/cgi-bin/epp/info

        EPPAuthURI              /epp/auth/login
        <Location /epp/auth>
                AuthType Basic
                AuthName "EPP"
                AuthUserFile /etc/apache2/htpasswd
                require valid-user
        </Location>
    </VirtualHost>
</IfModule>
```

    sudo a2enmod cgi
    sudo a2enmod authn_file # will be used for non implicit authentication URIs
    sudo htpasswd -c /etc/apache2/htpasswd test
    Type "test" when prompted
    cd /usr/lib/cgi-bin
    mkdir epp

Copy the files from $mod_epp/examples/cgis to /usr/lib/cgi-bin/epp 
