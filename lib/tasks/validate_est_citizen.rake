require 'syslog/logger'

namespace :validate_est_citizen do
  # bundle exec rake validate_est_citizen:check_it['38903110313']
  #
  desc 'Starts validating estonian citizen by isikukood'
  task :check_it, [:isikukood] => :environment do |t, args|
    WITH_DATA=false
    IN_JSON=false

    isikukood = args.isikukood

    esteid = EsteidLdap::Search.new
    result = esteid.search_by_ident(code: isikukood, with_data: WITH_DATA, in_json: IN_JSON)
    p "========Result||||||||"
    p result
  end


  def logger
    @logger ||= ActiveSupport::TaggedLogging.new(Syslog::Logger.new('registry'))
  end
end

