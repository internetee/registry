# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every 10.minutes do
  runner 'ZonefileSetting.generate_zonefiles'
end

set :output, 'log/cron.log'

# rbenv
set :job_template, 
  "/bin/bash -l -c 'export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; :job'"
