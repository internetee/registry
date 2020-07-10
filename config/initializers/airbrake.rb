Airbrake.configure do |config|
  config.host = ENV['airbrake_host']
  config.project_id = ENV['airbrake_project_id']
  config.project_key = ENV['airbrake_project_key']
  config.root_directory = Rails.root
  config.job_stats = false
  config.query_stats = false
  config.performance_stats = false
  config.logger =
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Logger.new(STDOUT, level: Rails.logger.level)
    else
      Logger.new(
        Rails.root.join('log', 'airbrake.log'),
        level: Rails.logger.level
      )
    end
  config.environment = ENV['airbrake_env'] || Rails.env
  config.ignore_environments = %w[test]
  config.blacklist_keys = Rails.application.config.filter_parameters
end
