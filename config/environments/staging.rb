Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  require 'syslog/logger'
  config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new(ENV['app_name'] || 'registry'))

  # if ENV["RAILS_LOG_TO_STDOUT"].present?
  #   logger           = ActiveSupport::Logger.new(STDOUT)
  #   logger.formatter = config.log_formatter
  #   config.logger = ActiveSupport::TaggedLogging.new(logger)
  # end
end
