require 'optparse'
require 'rake_option_parser_boilerplate'
require 'syslog/logger'
require 'active_record'

DAYS_INTERVAL = 365
SPAM_TIME_DELAY = 0.3
BATCH_SIZE = 100

namespace :company_status do
  # bundle exec rake company_status:check_all -- --days_interval=128 --spam_time_delay=0.3 --batch_size=100
  
  desc 'Starts verifying registrant companies job with optional days interval, spam time delay and batch size'
  task check_all: :environment do
    options = {
      days_interval: DAYS_INTERVAL,
      spam_time_delay: SPAM_TIME_DELAY,
      batch_size: BATCH_SIZE,
    }
  
    opts_hash = {
      days_interval: ["--days_interval=VALUE", Integer],
      spam_time_delay: ["--spam_time_delay=VALUE", Float],
      batch_size: ["--batch_size=VALUE", Integer]
    }
  
    banner = 'Usage: rake company_status:check_all -- [options]'
    options = RakeOptionParserBoilerplate.process_args(options: options,
                                                       banner: banner,
                                                       hash: opts_hash)

  
    CompanyRegisterStatusJob.perform_later(options[:days_interval], options[:spam_time_delay], options[:batch_size])
  end  
end
