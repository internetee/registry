Registry que server
===================

Que server responsibilites:

*  handle write type of communication between Registrant and Registry
*  handle future jobs for Registry
*  handle heavy load jobs for Registry

Installation
------------

Que can deploy either separaetly or along to Registry server depends on real load situation.
In both serarious que requires working Registry deployment and full access to Registry databases. 

Installation at deployed server:

    cd /home/registry/registry/current
    sudo cp doc/que/que_init_sample /etc/init.d/que # and edit it
    sudo chmod +x /etc/init.d/que
    sudo /etc/init.d/que          # for help and other commands
    sudo /etc/init.d/que start    # for manual start 
    sudo update-rc.d que defaults # for start in server boot

PID files
---------

All pid files are at log/que directory.

Debugging
---------

You can run que manually as well for debugging:

    cd /home/registry/registry/current

For all manual que tasks:

    RAILS_ENV=production bundle exec rake -T que    # for all que tasks for manual control
    rake que:clear           # Clear Que's job table
    rake que:drop            # Drop Que's job table
    rake que:migrate         # Migrate Que's job table to the most recent version (creating it if it doesn't exist)
    rake que:work            # Process Que's jobs using a worker pool

For all que daemon tasks what inist script uses

    RAILS_ENV=production bundle exec rake -T daemon # for all que daemon tasks what init script uses
    rake daemon:que          # Start que script
    rake daemon:que:restart  # Restart que daemon
    rake daemon:que:start    # Start que daemon
    rake daemon:que:status   # Status que daemon
    rake daemon:que:stop     # Stop que daemon
