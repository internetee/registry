System build
------------

All systems should run on Debian 7 or newer, 
however officially Debian 7 is supported and tested. 

### Manual build

* Consider using [RBENV](https://github.com/sstephenson/rbenv)
* Compile requried [ruby version](https://github.com/internetee/registry/blob/master/.ruby-version)
* [Phusion passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html)
* [Postgresql](http://www.postgresql.org/docs/)

Registry application is not tested with multi-threaded system (such as Puma) and 
it's not officially supported. Please use multi-process system instead (Passenger, Unicorn, Mongrel)

Use Phusion Passenger [official debian packages](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#install_on_debian_ubuntu) NB! Passenger runtime does not depend on ruby version, thus you can use multiple different ruby version apps with same passenger install. 

We also recommend to investigate 
[Passenger Optimization Guide](https://www.phusionpassenger.com/documentation/ServerOptimizationGuide.html) for proper configuration.


### For building gem libs

Please install following lib, otherwise your bundler install might not be successful.

    sudo apt-get install libxml2-dev

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

First increase the maximum possible value for the hitcount parameter
from its default value of 20 by setting the option 
ip_pkt_list_tot of the xt_recent kernel module. 
This can be done by creating an ip_pkt_list_tot.conf file in /etc/modeprobe.d/ which contains:

````
options xt_recent ip_pkt_list_tot=100
````

Once the file is created, reload the xt_recent kernel module via modprobe -r xt_recent && modprobe xt_recent or reboot the system.


#### Registrar, REPP, Restful-whois

````
#!/bin/bash
# Inspired and credits to Vivek Gite: http://www.cyberciti.biz/faq/iptables-connection-limits-howto/
IPT=/sbin/iptables
# Max connection in seconds
SECONDS=60
# Max connections per IP
BLOCKCOUNT=100
# default action can be DROP or REJECT or something else.
DACTION="REJECT"
$IPT -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
$IPT -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --rcheck --seconds ${SECONDS} --hitcount ${BLOCKCOUNT} -j ${DACTION}
````

#### EPP

````
#!/bin/bash
# Inspired and credits to Vivek Gite: http://www.cyberciti.biz/faq/iptables-connection-limits-howto/
IPT=/sbin/iptables
# Max connection in seconds
SECONDS=60
# Max connections per IP
BLOCKCOUNT=100
# default action can be DROP or REJECT or something else.
DACTION="REJECT"
$IPT -A INPUT -p tcp --dport 700 -i eth0 -m state --state NEW -m recent --set
$IPT -A INPUT -p tcp --dport 700 -i eth0 -m state --state NEW -m recent --rcheck --seconds ${SECONDS} --hitcount ${BLOCKCOUNT} -j ${DACTION}
````

#### Whois

````
#!/bin/bash
# Inspired and credits to Vivek Gite: http://www.cyberciti.biz/faq/iptables-connection-limits-howto/
IPT=/sbin/iptables
# Max connection in seconds
SECONDS=60
# Max connections per IP
BLOCKCOUNT=100
# default action can be DROP or REJECT or something else.
DACTION="REJECT"
$IPT -A INPUT -p tcp --dport 43 -i eth0 -m state --state NEW -m recent --set
$IPT -A INPUT -p tcp --dport 43 -i eth0 -m state --state NEW -m recent --rcheck --seconds ${SECONDS} --hitcount ${BLOCKCOUNT} -j ${DACTION}
````

