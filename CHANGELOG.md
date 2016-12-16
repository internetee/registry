16.12.2016
* Allow contact address processing to be configurable via admin
* EPP XML schema namespace "urn:ietf:params:xml:ns:epp-1.0" replaced with "https://epp.tld.ee/schema/epp-ee-1.0.xsd"
* EPP XML schema contact-eis-1.0 replaced with contact-ee-1.1

18.11.2016 
* Domain expiration emails are now sent out to admin contacts as well. Sending bug is fixed.
* Include detailed registrar's contact info in emails

07.11.2016 
* Use app time zone when calculating valid_to, outzone_at and delete_at domain attributes
* Treat domains as expired when expire_time is set to current time
* Improve domain's outzone and delete logic

25.10.2016 
* Outdated specs removed, failing specs fixed, rspec config improved

20.10.2016
* Travis CI integration added, New Relic removed

19.10.2016
* BUG fix: Record current time for outzone on domain:delete EPP request
* ForceDelete automatic notice: fixed et and ee wording to reflect the date the domain is actually deleted.

9.09.2016
* Registry:
  * domains expire now at the beginning of the date followed by the date of regsitration. Expiration and redemption grace periods now follow domainregulations more correctly and delete date returned in whois matches the date the domain is actually deleted (129684535)

31.08.2016
* Admin interface:
  * contact id supports wildcard search with '%' (129124951)
* Registry:
  * BUG: whodunnit filled with incorrect user reference in case of pending request confirmations and rejections (115693873)
  * domain_cron.rb now searches for domains to be archived using the end of the day parameter allowing it to be run at any time during the day (113430903)
* EPP:
  * Invalid use of GET is now logged and replied with proper error message instead of internal error (128054415)
* Portal for registrars
  * BUG fix: invoices now dipslay description entered by registrar on invoice request

9.08.2016
* Admin interface:
  * actions are now clickable in domain and contact history and return the initial epp request sent to registry (117806281)
  * access to archived domain and contact objects under settings (108869472)
  * BUG: noaccess fixed for contacts with incomplete ident data (120093749)
* Registry:
  * BUG: adding contact do a domain generated unnecessary log records (116761157)
  * linked state for a contact is now dynamic (116761157)
* Portal for registrars:
  * improved dnssec data presentation in ds data interface mode (118007975)
  * BUG: now all the ident data is returned for contacts with incomplete set (120093749)
* EPP
  * BUG: invalid error 2304 "Object status prohibits operation" (118822101)
  * BUG: invalid error 2302 "Nameserver already exists on this domain" (118822101)

14.07.2016
* Registry:
  * whois records generation fix in contact.rb model (#117612931)
  * english translation fix for pending_update_notification_for_new_registrant automated registrant message

16.06.2016
* EPP
  * BUG: XML syntax error for poll and logout if optional clTRID is missing (#121580929)
  * support for glue records with ipv6 addresses only (#120095555)

15.06.2016
* Portal for registrants
  * Notice on login screen on limited access to Estonian electronic IDs (#120182999)
* Admin interface:
  * epp log view has now reference to the object name for better usability (#118912395)
  * BUG: dnssec data missing from domain history view (#115762063)
  * BUG: internal error in doamin history view in case some contact has been deleted (#118300251)
* Registry:
  * all values sent over epp are now trimmed of beginning and trailing spaces (#117690107)
  * typo and form fixes for automated e-mail messages sent to domain contacts
* EPP:
  * BUG: error 2005 on adding IDN nameservers (#114677695)
  * BUG: nameserver lable maximum 63 char length validation handled inproperly (#114677695) - support currently limited to Estonian IDN characters.
  * BUG: validation passes out of range ident_type values - now limited to org, priv and birthday (#111601356)
  * BUG: internal error on hello (#120828283)
  * BUG: internal error broken incoming frame (#121580929)
* Deploy:
  * BUG: incorrect version in commit message on deploy - config/deploy-example.rb (#120259603)

20.05.2016
* Portal for registrars
  * domain details view new displays contact name in addition to ID (#117226457)
  * added an option to set veryfied = "yes" parameter to GUI for registrant change and domain delete opertions (#116209751)
* Admin interface
  * BUG: fixed number of sorting issues on different views (#117350717)
  * BUG: internal error on filtered list sorting (#115043065)
  * BUG: account activities csv export messes up registrars (#117702653)
  * usability fixes to history view (#115762063)
* Registry
  * epp-xml gem reference updated to v 1.0.5 (#116209751)
  * epp-xml gem is now taken from local repo https://github.com/internetee/epp-xml/blob/master, the version in RubyGems is not updated any more (#116209751)
  * BUG: domains set to force delete were deleted a day ahead of time (#117131083)
  * BUG: QUE - undefined method `code' for nil:NilClass - if contact is removed before Que gets to it (#117612061)
  * BUG: Que - uninitialized constant RegenerateWhoisRecordJob (#117986917)
* EPP
  * BUG: poll message on domain delete does not validate against .ee xml schemas (#118827261)
  * BUG: internal error on domain delete (#118159567)
* RestWHOIS
  * BUG: statuses not in array for not registered reserved and blocked domains (#118911315)

...

21.09.2015
* eis-1.0.xsd schema file updated without a new version, please publish a new updated schema file to public.

17.09.2015
* deploy-example.rb has been updated with `@cron_group`.

11.08.2015

* Possible to add whitelist_emails_for_staging list at application.yml

21.07.2015

* Possible to define custom trusted proxies at application.yml

20.07.2015

* New syntax for setting webclient IP-s (see config/application-example.yml)
* Example mina/deploy.rb renamed to mina/deploy-example.rb in order to not overwrite local deploy scripts

14.07.2015

* Updated que init script doc example, now status and stop works faster
* Updated registry server cronjob with mina cron:setup

07.07.2015

* Before applyling 20150707104937_refactor_reserved_domains.rb migration, enable hstore extension in db

01.07.2015

* Added que init script example at doc/que directory, please setup que accornding to doc/que/README.md

26.06.2015

* Added new relic license key ta application-example.yml, please update application.yml

22.06.2015

* Update zonefile

16.06.2015

* Application time_zone should be defined at application.yml, updated application-exaple.yml 

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

* Added separate data update, all data migration locate at db/data, more info 'rake -T data'

29.05.2015

* Removed old 'iptables_counter_update_command' and added 'iptables_counter_enabled'
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
