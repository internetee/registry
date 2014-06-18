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

**NB! Beacause Rack multipart parser expects specifically formatted content boundaries, the mod_epp needs to be modified before building**

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

* `a2ensite epp`
* `sudo service apache2 restart`

Try it out:

* Fire up your appserver (I tested this setup with Unicorn)
* `cd $mod_epp`
* `./epptelnet.pl localhost 1701`

You should receive the greeting from the registry server.
Wait for a complete paragraph of text on STDIN before sending EPP/TCP frame.

```xml
<epp><command>
  <login>
    <clID>test</clID>
    <pw>test</pw>
  </login>
  <clTRID>sample1trid</clTRID>
</command></epp>
```

Alternative virtual host config is as follows:
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
