### Application build and update

For application deployment we are using faster [Mina](https://github.com/mina-deploy/mina) 
instead of Capistrano.

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
