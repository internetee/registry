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

module DomainNameRegistry

  # Add "db" to the list hosts on which you can run `rake db:setup:all`
# Only allow that in test and development.
if ['development', 'test'].include?(Rails.env)
  ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS << "db"
end

module Registry
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['time_zone'] || 'Tallinn'  # NB! It should be defined,
                                                      # otherwise ActiveRecord usese other class internally.

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.default_locale = :en

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    # Autoload all model subdirs
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << config.root.join('lib', 'validators')

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
      g.template_engine :erb
      g.jbuilder false
      g.test_framework nil
    end

    registrant_portal_uri = URI.parse(ENV['registrant_url'])
    config.action_mailer.default_url_options = { host: registrant_portal_uri.host,
                                                 protocol: registrant_portal_uri.scheme }

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

    config.action_view.default_form_builder = 'DefaultFormBuilder'
    config.secret_key_base = Figaro.env.secret_key_base
  end
end

require 'validates_email_format_of'
