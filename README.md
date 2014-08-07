Domain Registry
===============

Full stack top-level domain (TLD) management.


Installation
------------

### Registry app 

Usual Rails 4 app installation, rvm and bundler are your friends. 

    git clone git@github.com:internetee/registry.git

    cd registry
    rvm install ruby-2.1.2
    bundle
    rake db:setup

### Apache with patched mod_epp (Debian 7/Ubuntu 14.04 LTS)

    sudo apt-get install apache2

    sudo apt-get install apache2-threaded-dev # needed to compile mod_epp
    wget sourceforge.net/projects/aepps/files/mod_epp/1.10/mod_epp-1.10.tar.gz
    tar -xzvf mod_epp-1.10.tar.gz
    cd mod_epp-1.10

Patch mod_epp for Rack. Beacause Rack multipart parser expects specifically 
formatted content boundaries, the mod_epp needs to be modified before building:

    wget https://github.com/internetee/registry/raw/master/doc/patches/mod_epp_1.10-rack-friendly.patch    
    patch < mod_epp_1.10-rack-friendly.patch
    apxs2 -a -c -i mod_epp.c

Enable ssl:

    sudo a2enmod proxy_http
    sudo mkdir /etc/apache2/ssl
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
    sudo nano /etc/apache2/sites-available/epp_ssl.conf

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

For plain TCP EPP configuration, see below (may be useful for debugging purposes).

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
    <clID>test</clID>
    <pw>test</pw>
  </login>
  <clTRID>sample1trid</clTRID>
</command></epp>
```
* Before running tests for the first time: `rake db:seed`
* Run tests: `rake`
* Run EPP tests: `rake test:epp`
* Run all but EPP tests: `rake test:other`

To see internal errors while testing EPP
    
    unicorn -E test -p 8989
    rake spec:epp


Apache mod_epp testing/debugging
--------------------------------

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

