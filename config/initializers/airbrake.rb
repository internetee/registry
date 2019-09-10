Airbrake.configure do |config|
  config.host = ENV['airbrake_host']
  config.project_id = ENV['airbrake_project_id']
  config.project_key = ENV['airbrake_project_key']

  config.environment = ENV['airbrake_env'] || Rails.env
  config.ignore_environments = %w(development test)
end
