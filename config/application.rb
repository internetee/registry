require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'csv'
require 'rails/all'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Registry
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['time_zone'] || 'Tallinn'  # NB! It should be defined, 
                                                      # otherwise ActiveRecord usese other class internally.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    # Autoload all model subdirs
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths << Rails.root.join('lib')

    # Add the fonts path
    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

    # Precompile additional assets
    config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    config.assets.precompile += %w(admin-manifest.css admin-manifest.js)
    config.assets.precompile += %w(registrar-manifest.css registrar-manifest.js)
    config.assets.precompile += %w(registrant-manifest.css registrant-manifest.js)

    # Active Record used to suppresses errors raised within
    # `after_rollback`/`after_commit` callbacks and only printed them to the logs.
    # In the next version, these errors will no longer be suppressed.
    # Instead, the errors will propagate normally just like in other Active Record callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_record.schema_format = :sql

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
    end

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.smtp_settings = {
      address:              ENV['smtp_address'],
      port:                 ENV['smtp_port'],
      enable_starttls_auto: ENV['smtp_enable_starttls_auto'] == 'true',
      user_name:            ENV['smtp_user_name'],
      password:             ENV['smtp_password'],
      authentication:       ENV['smtp_authentication'],
      domain:               ENV['smtp_domain'],
      openssl_verify_mode:  ENV['smtp_openssl_verify_mode']
    }
  end
end

require 'validates_email_format_of'
