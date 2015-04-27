# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# rbenv support
rbenv = 'export PATH="$HOME/.rbenv/bin:$PATH";eval "$(rbenv init -)";'
path  = Whenever.path.sub(%r{\/releases\/.*}, '/current')
set :job_template, "/bin/bash -l -c '#{rbenv} :job'"
job_type :runner, "cd #{path} && bin/rails r -e :environment \":task\" :output"

# cron output
set :output, 'log/cron.log'

every 10.minutes do
  runner 'ZonefileSetting.generate_zonefiles'
end

every 6.months, at: '12pm' do
  runner 'Contact.destroy_orphans'
end

every 1.days, at: '12:10pm' do
  runner 'Invoice.cancel_overdue_invoices'
end
