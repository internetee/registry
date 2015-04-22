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
