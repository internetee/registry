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

14.01.2015

* Update your Apache EPP conf file, add "EPPRawFrame raw_frame", inspect example file at Readme
  Otherwise new master EPP will not work.
