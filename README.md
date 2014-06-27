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

**NB! Beacause Rack multipart parser expects specifically formatted content boundaries, the mod_epp needs to be modified before building:**

```diff
diff --git a/mod_epp.c b/mod_epp.c
index 60c0004..bf2b6ab 100644
--- a/mod_epp.c
+++ b/mod_epp.c
@@ -756,7 +756,7 @@ sprintf(content_length, "%lu", strlen(EPP_CONTENT_FRAME_CGI)
                                strlen(conf->raw_frame)
                                + er->orig_xml_size) : 0));

-apr_table_set(r->headers_in, "Content-Type", "multipart/form-data; boundary=--BOUNDARY--");
+apr_table_set(r->headers_in, "Content-Type", EPP_CONTENT_TYPE_CGI);
 apr_table_set(r->headers_in, "Content-Length", content_length);
 apr_table_set(r->headers_in, "Cookie", er->ur->cookie);

diff --git a/mod_epp.h b/mod_epp.h
index d8c463e..7f6e320 100644
--- a/mod_epp.h
+++ b/mod_epp.h
@@ -96,10 +96,10 @@ module AP_MODULE_DECLARE_DATA epp_module;
 #define EPP_DEFAULT_RC_HEADER "X-EPP-Returncode"


-#define EPP_CONTENT_TYPE_CGI "multipart/form-data; boundary=--BOUNDARY--"
-#define EPP_CONTENT_FRAME_CGI "----BOUNDARY--\r\nContent-Disposition: form-data; name=\"frame\"\r\n\r\n"
-#define EPP_CONTENT_RAW_CGI "\r\n----BOUNDARY--\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n"
-#define EPP_CONTENT_CLTRID_CGI "\r\n----BOUNDARY--\r\nContent-Disposition: form-data; name=\"clTRID\"\r\n\r\n"
+#define EPP_CONTENT_TYPE_CGI "multipart/form-data; boundary=--BOUNDARY"
+#define EPP_CONTENT_FRAME_CGI "----BOUNDARY\r\nContent-Disposition: form-data; name=\"frame\"\r\n\r\n"
+#define EPP_CONTENT_RAW_CGI "\r\n----BOUNDARY\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n"
+#define EPP_CONTENT_CLTRID_CGI "\r\n----BOUNDARY\r\nContent-Disposition: form-data; name=\"clTRID\"\r\n\r\n"
 #define EPP_CONTENT_POSTFIX_CGI "\r\n----BOUNDARY--\r\n"
```

* `sudo apxs2 -a -c -i mod_epp.c`
* `sudo a2enmod cgi`
* `sudo a2enmod authn_file` (Will be used for non implicit authentication URIs, can be removed in the future)
* `sudo a2enmod proxy_http`
* `sudo htpasswd -c /etc/apache2/htpasswd test` (can be removed in the future)
* Type "test" when prompted
* `cd /usr/lib/cgi-bin`
* `mkdir epp`
* Copy the files from $mod_epp/examples/cgis to /usr/lib/cgi-bin/epp (once in production, majority of these scripts will not be needed (maybe only double the error script for failover))
* `sudo mkdir /etc/apache2/ssl`
* `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt`
* `sudo nano /etc/apache2/sites-available/epp_ssl.conf`

For development configuration, add:
```apache
<IfModule mod_epp.c>
  <Directory "/usr/lib/cgi-bin/epp">
    Options ExecCGI
    SetHandler cgi-script
  </Directory>

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

Note: Its best to go with two virtual hosts, one for test and one for dev, then you don't have to worry about quitting the dev appserver for running tests (because of colliding ports).

For plain TCP EPP configuration, see below (may be useful for debugging purposes).

* `sudo a2ensite epp_ssl`
* `sudo service apache2 restart`

Try it out:

* Fire up your appserver on port 8989 (This setup is tested with Unicorn)
* `cd $mod_epp`
* `./epptelnet.pl localhost 701 -s`

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

* Run tests: `rake`
* Run all but EPP tests: `rake test:other`

To see internal errors while testing EPP
* `unicorn -E test -p 8989`
* `rake spec:epp`

---

Configuration on plain TCP EPP is as follows:

Add:
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

For debugging purposes, standalone CGI scripts can be used:  
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
