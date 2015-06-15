15.06.2015

* Apache config update: now only TLSv1.2 allowed with whitelisted chipers, please review all SSL config parameters

08.06.2015

* Add sk service name to application.yml
* Renew zonefile procedure

02.06.2015

* Added possibility to overwrite legal document types at application.yml level.

01.06.2015

* Added separate data update, all data migration locate at db/data, more info 'rake -T data'

29.05.2015

* Removed old 'iptables_counter_update_command' and added 'iptables_counter_enabled'

26.05.2015

* Updated deploy script, now staging comes from staging branch

25.05.2015

* Added iptables counter command to application-example.yml
* Add update application.yml with correct `sk_digi_doc_service_endpoint`

22.05.2015

* Add `RequestHeader set SSL_CLIENT_CERT "%{SSL_CLIENT_CERT}s` to apache config (see README for details)

20.05.2015

* Added documentation how to configure linux firewall about rate limits, scirpts and more info at doc/debian_build_doc.md

19.05.2015

* Added possibility to define NewRelic app_name at application.yml file with 'new_relic_app_name' attribute. 

18.05.2015

* Added Registrant database example file: config/database-example-registrant.yml

16.05.2015

* Security config update. Please replace all Location and RedirectMatch 
  in Admin, Registrar and Registrant Apache2 config. New one are in readme.

15.05.2015

* Refer to doc/certificates.md for ID card login, note that CRL files in Apache config are not paths to CRL directory. (SSLCARevocationFile -> SSLCARevocationPath)

15.05.2015

* Added instractions for apache2 reload without password for Registrant/Registrar, 
  more info at doc/certificates.md

14.05.2015

* Changed and added some new smtp enviroment variables. More info at application-example.yml

13.05.2015

* Added Registrant portal and apache config example
* Added mina deploy script for registrant
* Added new environment for EPP server: 'registrant_url'

12.05.2015

* Ruby version updated to 2.2.2

11.05.2015

* Registrar: only dev can skip pki login certificate, 
  please be sure all application.yml and apache conf is correctly setup for pki
* Updated Registrar Apache example: added user name directive example config

24.04.2015

* Update zonefile procedure

23.04.2015

* Add `bank_statement_import_dir: 'import/legal_documents'` to application.yml, run `mina setup`

22.04.2015

* Configure smtp (see application-example.yml)

22.04.2015

* Whois database schema updated. Please reset whois database and run `rake whois:schema:load`

21.04.2015

* Install packages for wkhtmltopdf (see readme)
* Add `bank_statement_import_dir: 'import/bank_statements'` to application.yml, run `mina setup`

15.04.2015

* Added whois tasks, more info with rake -T whois

02.04.2015

* Depricated DelayedJob, kill all running delayed jobs if needed

27.03.2015
 
* Integrated DEPP engine to Registrar. Please note new DEPP configuration in application-example.yml
* Patched mod_epp for larger frames, reinstall mod_epp with patches found in README and restart Apache.

25.03.2015

* Added new cronjob for destroying orphaned contacts. Update cron by running `mina cron:setup` in registry project

24.03.2015

* New Registrar virtualhost added. Please refer to readme for the configuration.
* Note the improved configuration for the registry virtualhost:

```
# Rewrite /login to /admin/login
RewriteEngine on
RewriteCond %{REQUEST_URI} ^/login [NC]
RewriteRule ^/(.*) /admin/$1 [PT,L,QSA]

<Location ~ "/.+/" >
  Deny from all
</Location>

<Location ~ "/(admin|assets)\/.+">
  Allow from all
</Location>
```

19.03.2015

* New REPP virtualhost added. Please refer to readme for the configuration.
* Choose new domain for REPP interface and reconfigure repp_url parameter in webclient's application.yml

16.03.2015

* ruby upgraded to version 2.2.1, added RBENV upgrade howto to debian doc at: doc/debian_build_doc.md

27.02.2015

* Simplified config/application-example.yml, 
  now system will check if all required settings are present in application.yml 

19.02.2015

* Cetrificate only enabled, please setup certificates following doc/certificate.md document.

20.01.2015

* Added dedicated mina cron:setup and mina cron:clear for manual cron management.
  Automatic management during deploy removed.
* Added mina config for epp: "mina eppst deploy" and "mina epppr deploy" 

19.01.2015

* Added application-exapmle.yml and removed application.yml from repo, please 
  add config/application.yml back when deploying:
  cp current/config/application-example.yml shared/config/application.yml # and edit it
* Removed config/initilizers/devise_secret.rb, use application.yml

16.01.2015

* Added new rake tasks: rake db:all:setup to setup all databases
  Find out more tasks for all databases with rake -T db:all

* Staging env added, please change apache conf in staging servers to "RailsEnv staging"
  Then you need to add or update staging section in
  --> config/database.yml
  --> config/secrets.yml
  --> config/application.yml

15.01.2015

* Registry api log and whois database added, please update your database.yml,
  you can view updated config at config/database-example.yml
* Upgraded to Rails 4.2 and ruby 2.2.0, be sure you have ruby 2.2.0 in your rbenv 
  NB! Update you passenger deb install, it should have recent fix for ruby 2.2.0

14.01.2015

* Update your Apache EPP conf file, add "EPPRawFrame raw_frame", inspect example file at Readme
  Otherwise new master EPP will not work.
