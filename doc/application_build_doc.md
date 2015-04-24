Application build and update
----------------------------

### Debian setup

* [Debian build](/doc/debian_build_doc.md)


### Certificates setup

* [Certificates setup](/doc/certificates.md)


### Production env setup

For production you probably would like to create databases to your locale, example: 

    create database registry_production owner registry encoding 'UTF-8' LC_COLLATE 'et_EE.utf8' LC_CTYPE 'et_EE.utf8' template template0;

Deploy overview: (database schema should be loaded and seeds should be present)

    # at your local machine
    git clone git@github.com:internetee/registry.git
    cd registry
    rbenv local 2.2.1 # more info about rbenv at debian doc
    gem install mina
    mina pr setup # one time, only creates missing directories
    ssh registry

    # at your server
    cd registry
    cp current/config/application-example.yml shared/config/application.yml # and edit it
    cp current/config/database-example.yml shared/config/database.yml # and edit it

    vi /etc/apache2/sites-enabled/registry.conf # add conf and all needed serts
    vi /etc/apache2/sites-enabled/epp.conf # add epp conf, restart apache
    exit
    # at your local machine
    mina pr deploy # this is command you use in every application code update



### Deploy script setup

We recommend [Mina](https://github.com/mina-deploy/mina) instead of Capistrano for deployment.

All deploy code locates at config/deploy.rb file.

First add shortcuts to your local machine ssh config file, 

```
~/.ssh/config file:
# staging
Host registry-st
  HostName YOUR-REGISTRY-STAGING-SERVER-IP
  User registry

# production
Host registry
  HostName YOUR-REGISTRY-SERVER-IP
  User registry

# staging
Host eppweb-st
  HostName YOUR-EPPWEB-STAGING-SERVER-IP
  User registry

# production
Host eppweb
  HostName YOUR-EPPWEB-SERVER-IP
  User registry

# staging
Host whois-st
  HostName YOUR-WHOIS-STAGING-SERVER-IP
  User registry

# production
Host whois
  HostName YOUR-WHOIS-SERVER-IP
  User registry
```

Those shortcuts should be same as in config/deploy.rb script, 
otherwise mina will not deploy.

Mina help and all mina commands:

    mina -h
    mina -T

Setup application directories for a new server:

    mina setup     # staging
    mina pr setup  # production 

Deploy new code:

    mina deploy    # staging
    mina pr deploy # production

Rollback to previous release:

    mina rollback    # staging
    mina pr rollback # production 

General rake and mina tips:

    rake -T     # list all rake commands
    rake -T db  # list all database related commands
    mina -T     # list all mina deploy commands


### CRON

Crontab can be setup after deploy. Jobs can be viewed [here](/config/schedule.rb).

    mina pr cron:setup # to update the crontab.
    mina pr cron:clear # to clear crontab.

### Zonefile procedure

Zonefile procedure must be set up after deploy. The same command must be run whenever procedure is updated (see changelog).

    bundle exec rake zonefile:replace_procedure
