Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true
  config.eager_load = true

  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.active_support.test_order = :random

  config.active_support.deprecation = :raise
  config.logger = ActiveSupport::Logger.new(nil)

  config.action_view.raise_on_missing_translations = true

  # If set to :null_store, Setting.x returns nil after first spec runs (database is emptied)
  config.cache_store = :memory_store
end

Que.mode = :sync