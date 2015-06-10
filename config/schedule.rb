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

every :day, at: '12:10pm' do
  runner 'Invoice.cancel_overdue_invoices'
end

every :day, at: '12:15pm' do
  runner 'Domain.expire_domains'
end

every 3.hours do
  runner 'Certificate.update_crl'
end

every :hour do
  runner 'Domain.start_expire_period'
  runner 'Domain.start_redemption_grace_period'
  runner 'Domain.start_delete_period'
end

every 42.minutes do
  runner 'Domain.destroy_delete_candidates'
end
