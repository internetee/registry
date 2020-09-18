Testing
-------

Setup test databases:

    RAILS_ENV=test rake db:setup:all

Run basic test (no EPP tests):

    rake


Testing EPP
===========

In order to test EPP, you have to configure apache to handle EPP request correctly.

### Apache site config

First you should have mod_epp installed, please follow main README for doing it.

Apache site config for autotest, add file to /etc/apache2/sites-enabled/epp-autotest.conf

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
    EPPRawFrame             raw_frame

    ProxyPass /proxy/ http://localhost:8989/epp/

    EPPAuthURI              implicit
    EPPReturncodeHeader     X-EPP-Returncode
  </VirtualHost>
</IfModule>
```



* Run all tests with temp server running automatically on port 8989:

    rake test


Manual debugging
================

### Apache mod_epp manual debugging

Debugging Apache mod_epp without Registry app.

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


Allowed testing email list
==========================

All allowed testing emails are located under config/initialized/settings.rb file.

