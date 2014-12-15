Domain Registry
===============

Full stack top-level domain (TLD) management.

* [Installation](https://github.com/internetee/registry#installation)
* [Testing](https://github.com/internetee/registry#testing)
* [Documentation](https://github.com/internetee/registry#documentation)
* [Deployment](https://github.com/internetee/registry#deployment)


Installation
------------

### Registry app 

Usual Rails 4 app installation, rvm and bundler are your friends. 

    git clone git@github.com:internetee/registry.git

    cd registry
    rvm install ruby-2.1.2
    bundle
    rake db:setup
    mv config/secrets-example.yml config/secrets.yml # generate your own keys

If you desire other database locale, you have to create database manually first and
skip rake db:setup. Example: 
    
    create database registry owner registry encoding 'UTF-8' LC_COLLATE 'et_EE.utf8' LC_CTYPE 'et_EE.utf8' template template0;
    rake db:schema:load
    rake db:seeds

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

For development configuration, add:
```apache
<IfModule mod_epp.c>
  Listen 701
  <VirtualHost *:701>
    SSLEngine on
    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key

    SSLVerifyClient optional_no_ca

    EPPEngine On
    EPPCommandRoot          /proxy/command
    EPPSessionRoot          /proxy/session
    EPPErrorRoot            /proxy/error
    
    ProxyPass /proxy/ http://localhost:8989/epp/

    EPPAuthURI              implicit
    EPPReturncodeHeader     X-EPP-Returncode
  </VirtualHost>
</IfModule>
```

Configuration on plain TCP EPP is as follows:
```apache
<IfModule mod_epp.c>
  <Directory "/usr/lib/cgi-bin/epp">
    Options ExecCGI
    SetHandler cgi-script
  </Directory>

  Listen  1701
  <VirtualHost *:1701>
    EPPEngine On
    EPPCommandRoot          /proxy/command
    EPPSessionRoot          /proxy/session
    ProxyPass /proxy/ http://localhost:8080/epp/

    EPPErrorRoot         /cgi-bin/epp/error

    EPPAuthURI implicit
    EPPReturncodeHeader     X-EPP-Returncode
  </VirtualHost>
</IfModule>
```

Note: Its best to go with two virtual hosts, one for test and one for dev, 
then you don't have to worry about quitting 
the dev appserver for running tests (because of colliding ports).

    sudo a2ensite epp_ssl
    sudo service apache2 restart

Try it out:

Fire up your appserver on port 8989 (This setup is tested with Unicorn)

    cd $mod_epp
    ./epptelnet.pl localhost 701 -s

You should receive the greeting from the registry server.  
Wait for the greeting message on the STD, then send EPP/TCP frame:

```xml
<epp><command>
  <login>
    <clID>registrar1</clID>
    <pw>test1</pw>
  </login>
  <clTRID>sample1trid</clTRID>
</command></epp>
```

All demo data locates at: 

    db/seeds.rb

There are two type of users: admin users and EPP users.


### EPP web client

Please follow EPP web client readme:

    https://github.com/internetee/EPP-web-client


### WHOIS server

Please follow WHOIS server readme:

    https://github.com/internetee/whois


Testing
-------

* Before running tests for the first time: `RAILS_ENV=test rake db:seed`
* Run tests: `rake`
* Run EPP tests: `rake test:epp`
* Run all but EPP tests: `rake test:other`

To see internal errors while testing EPP
    
    unicorn -E test -p 8989
    rake spec:epp

### Apache mod_epp testing/debugging

Testing Apache mod_epp without Registry app.

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


Documentation
-------------

[EPP request-response examples](https://github.com/internetee/registry/blob/master/doc/epp-doc.md)


Deployment
----------

### System build

Officially Debian 7 is supported and tested. 

You can use or find ideas how to build up production servers using 
sysadmin tool [Babushka](https://github.com/benhoskings/babushka).

Unofficial build scripts locate at: https://github.com/priit/babushka-deps
Those scripts are not dedicated to Registry, but more focuse on general
Ruby on Rails application deployment in various situatians.

Quick overview. Use 'registry' for username and app name when asked.

    # on server side
    apt-get install curl
    sh -c "`curl https://babushka.me/up`"
    babushka priit:app_user
    babushka priit:app

Please inspect those scripts before running anything, 
they might not be complete or might have serious bugs. You are free to fork it.

Alternatively you can build up everything manually, required components:

Consider using RBENV: https://github.com/sstephenson/rbenv
Compile requried ruby version: https://github.com/internetee/registry/blob/master/.ruby-version
Phusion passenger with apache: https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html
Postgresql documents: http://www.postgresql.org/docs/


### Application build and update

For application deployment we are using faster [Mina](https://github.com/mina-deploy/mina) 
instead of Capistrano.

All deploy code locates at config/deploy.rb file.

First add 'testregistry' and 'registry' to your .ssh/config file:

```
# staging
Host testregistry
  HostName YOUR-SERVER-IP
  User registry

# production
Host registry
  HostName YOUR-SERVER-IP
  User registry
```

Mina help and all mina commands:

    mina -h
    mina -T

Setup application directories for a new server:

    mina setup     # staging
    mina pr setup  # production 

Deploy new code:

    mina deploy    # staging
    mina pr deploy # production

