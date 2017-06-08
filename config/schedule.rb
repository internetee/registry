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

if @cron_group == 'registry'
  every 10.minutes do
    runner 'DNS::Zone.generate_zonefiles'
  end

  every 6.months, at: '12:01am' do
    runner 'Contact.destroy_orphans'
  end

  every :day, at: '12:10am' do
    runner 'Invoice.cancel_overdue_invoices'
  end

  # TODO
  # every :day, at: '12:15am' do
    # runner 'Domain.expire_domains'
  # end

  every :day, at: '12:20am' do
    runner 'DomainCron.clean_expired_pendings'
  end

  every 3.hours do
    runner 'Certificate.update_crl'
  end

  every 42.minutes do
    runner 'DomainCron.destroy_delete_candidates'
  end

  every 45.minutes do
    runner 'DomainCron.start_expire_period'
  end

  every 50.minutes do
    runner 'DomainCron.start_delete_period'
  end

  every 52.minutes do
    runner 'DomainCron.start_redemption_grace_period'
  end

  every '0 0 1 * *' do
    runner 'Directo.send_monthly_invoices'
  end

  every :day, at: '19:00pm' do
    runner 'Directo.send_receipts'
  end if @environment == 'production'
end

every 10.minutes do
  runner 'Setting.reload_settings!'
end
