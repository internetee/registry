registry
========

###To install and configure mod_epp (on Ubuntu 14.04 LTS)

* `sudo apt-get install apache2`
* `sudo apt-get install apache2-threaded-dev`
* `sudo apt-get install apache2-utils`
* `sudo apt-get install apache2-dbg` (Actually I don't think this is needed, but while debugging I installed this too)
* Download [mod_epp 1.10](http://sourceforge.net/projects/aepps/)
* `tar -xzf mod_epp-1.10.tar.gz`
* `cd mod_epp-1.10`
* `sudo apxs2 -a -c -i mod_epp.c`
* `sudo a2enmod cgi`
* `sudo a2enmod authn_file`
* `sudo a2enmod proxy_http`
* `sudo htpasswd -c /etc/apache2/htpasswd test`
* Type "test" when prompted

* `cd /usr/lib/cgi-bin`
* `mkdir epp`
* Copy the files from $mod_epp/examples/cgis to /usr/lib/cgi-bin/epp (this is just for now)
* `cd /etc/apache2/sites-available`
* `nano epp.conf`

Add:
```
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

* `sudo service apache2 restart`

Try it out:

* `cd $mod_epp`
* `./epptelnet.pl localhost 1701`

You should receive the freeting from the registry server.


Alternative virtual host config is as follows:
This needs a static greeting file, so you will have to make /var/www writable.

```
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
        # we can redirect to static pages.
        Alias /cgi-bin/epp/session/hello /var/www/html/epp/session-hello


        # or to specialized scripts
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
