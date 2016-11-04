System build
------------

All systems should run on Debian 7 or newer, 
however officially Debian 7 is supported and tested. 

### Manual build

* Consider using [RBENV](https://github.com/sstephenson/rbenv)
* Compile requried [ruby version](https://github.com/internetee/registry/blob/master/.ruby-version)
* [Phusion passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html)
* [Postgresql](http://www.postgresql.org/docs/) (requires postgresql-contrib package)
* [Mailcatcher](https://mailcatcher.me/) (optional)

Registry application is not tested with multi-threaded system (such as Puma) and 
it's not officially supported. Please use multi-process system instead (Passenger, Unicorn, Mongrel)

Use Phusion Passenger [official debian packages](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#install_on_debian_ubuntu) NB! Passenger runtime does not depend on ruby version, thus you can use multiple different ruby version apps with same passenger install. 

We also recommend to investigate 
[Passenger Optimization Guide](https://www.phusionpassenger.com/documentation/ServerOptimizationGuide.html) for proper configuration.


### For building gem libs

Please install following lib, otherwise your bundler install might not be successful.

    sudo apt-get install libxml2-dev

### For generating pdfs

    sudo apt-get install libxrender1 libfontconfig1

### RBENV install

    cd /home/registry
    git clone https://github.com/sstephenson/rbenv.git /home/registry/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git /home/registry/.rbenv/plugins/ruby-build

### RBENV upgrade

    cd .rbenv
    git pull origin master
    cd plugins/ruby-build
    git pull origin master


### Firewall rate limit config

First increase the maximum possible value form 20 to 100 of the hitcount parameter.
ip_pkt_list_tot of the xt_recent kernel module. Secondly change /proc/net/xt_recent/ permissions so, epp user can modify the tables.
This can be done by creating an ip_pkt_list_tot.conf file in /etc/modeprobe.d/ which contains:

````
options xt_recent ip_pkt_list_tot=100 ip_list_uid=eppuseruid ip_list_gid=eppusergid
````

Once the file is created, reload the xt_recent kernel module via modprobe -r xt_recent && modprobe xt_recent or reboot the system.

#### Registrar, REPP, Restful-whois

````
#!/bin/bash
iptables -A INPUT -p tcp --dport 443 -m recent --name repp  --rcheck --seconds 60 --hitcount 25 -j DROP
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --set --rsource --name repp -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m recent --name rwhois  --rcheck --seconds 60 --hitcount 25 -j DROP
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set --rsource --name rwhois -j ACCEPT

````

#### Whois

````
#!/bin/bash
iptables -A INPUT -p tcp --dport 43 -m recent --name whois --rsource --rcheck --seconds 60 --hitcount 25 -j LOG --log-prefix "whois limit: " --log-level warning
iptables -A INPUT -p tcp --dport 43 -m recent --name whois --rsource --rcheck --seconds 60 --hitcount 25 -j REJECT
iptables -A INPUT -p tcp --dport 43 -m recent --set --rsource --name whois -j ACCEPT

````

#### EPP

Configure epp server ip in applicatin.yml
iptables_server_ip: 'x.x.x.x'
Iptables hitcounter is updated by application. For every registrar there is one recent table, where the request counters are stored, registrar handles and sources ips are "connected" with iptables rules.

````
#!/bin/bash


iptables -N CHKLIMITS

iptables -A CHKLIMITS -p tcp --dport 700 -s $REGISTRAR_SOURCE -m recent --name $REGISTRAR_CODE --rdest --rcheck --hitcount 100 --seconds 60 -j DROP
iptables -A CHKLIMITS -p tcp --dport 700 -s $REGISTRAR_SOURCE2 -m recent --name $REGISTRAR_CODE --rdest --rcheck --hitcount 100 --seconds 60 -j DROP
iptables -A CHKLIMITS -p tcp --dport 700 -s $REGISTRAR2_SOURCE -m recent --name $REGISTRAR2_CODE --rdest --rcheck --hitcount 100 --seconds 60 -j DROP
iptables -A CHKLIMITS -p tcp --dport 700 -s $REGISTRAR2_SOURCE2 -m recent --name $REGISTRAR2_CODE --rdest --rcheck --hitcount 100 --seconds 60 -j DROP

iptables -A INPUT -p tcp --dport 700 -j CHKLIMITS
````
#### Mailcatcher for staging (optional)

We recommend using mailcatcher for staging env, so that all outgoing mails are catched and not actualy sent ou.
The mailcatcher website explains how it should be intsalled and configured.
[Mailcatcher](https://mailcatcher.me/)
`````

