System build
------------

All systems should run on Debian 7 or newer, 
however officially Debian 7 is supported and tested. 

### Using babushka autoscripts

You can use or find ideas how to build up production servers using 
sysadmin tool [Babushka](https://github.com/benhoskings/babushka).

Unofficial build scripts locate at: https://github.com/priit/babushka-deps
Those scripts are not dedicated to Registry, but more focuse on general
Ruby on Rails application deployment in various situatians.
Please fork and customize dedicated to your system.

Quick overview, how to use it. 
Use 'registry' for username and app name when asked.

    # on server side
    apt-get install curl
    sh -c "`curl https://babushka.me/up`"
    babushka priit:app_user
    babushka priit:app

Please inspect those scripts before running anything, 
they might not be complete or might have serious bugs. You are free to fork it.


### Manual build

Alternatively you can build up everything manually, required components:

* Consider using [RBENV](https://github.com/sstephenson/rbenv)
* Compile requried [ruby version](https://github.com/internetee/registry/blob/master/.ruby-version)
* [Phusion passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html)
* [Postgresql](http://www.postgresql.org/docs/)

Registry application is not tested with multi-threaded system (such as Puma) and 
it's not officially supported. Please use multi-process system instead (Passenger, Unicorn, Mongrel)

We also recommend to investigate 
[Passenger Optimization Guide](https://www.phusionpassenger.com/documentation/ServerOptimizationGuide.html) for proper configuration.

Some additional suggestions:

    * Install application under dedicated user home directory, such as /home/registry/registry Handy to ssh in and start debugging.
    * Use Phusion Passenger [official debian packages](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#install_on_debian_ubuntu) NB! Passenger runtime does not depend on ruby version, tuhs you can use multiple different ruby version apps with same passenger install. 
