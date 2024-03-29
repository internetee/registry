require_relative 'boot'

require 'rails/all'
require 'English'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Add "db" to the list hosts on which you can run `rake db:setup:all`
# Only allow that in test and development.
if ['development', 'test'].include?(Rails.env)
  ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS << "db"
end

module DomainNameRegistry
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoloader = :zeitwerk

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
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    # Autoload all model subdirs
    # config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    # config.autoload_paths += Dir[Rails.root.join('app', 'lib', '**/')]
    # config.autoload_paths += Dir[Rails.root.join('app', 'interactions', '**/')]
    config.eager_load_paths << config.root.join('lib', 'validators')
    config.eager_load_paths << config.root.join('app', 'lib')
    config.watchable_dirs['lib'] = %i[rb]

    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.template_engine :erb
      g.test_framework nil
    end

    config.action_mailer.default_url_options = { protocol: ENV['action_mailer_default_protocol'],
                                                 host: ENV['action_mailer_default_host'],
                                                 port: ENV['action_mailer_default_port'] }

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
    config.action_mailer.default_options = { from: ENV['action_mailer_default_from'] }

    config.action_mailer.interceptors = ["Interceptors::PunycodeInterceptor"]

    config.action_view.default_form_builder = 'DefaultFormBuilder'
    config.secret_key_base = Figaro.env.secret_key_base

    # nil will use the "default" queue
    # some of these options will not work with your Rails version
    # add/remove as necessary
    config.action_mailer.deliver_later_queue_name = nil # defaults to "mailers"
    config.active_storage.queues.analysis   = nil       # defaults to "active_storage_analysis"
    config.active_storage.queues.purge      = nil       # defaults to "active_storage_purge"
    config.active_storage.queues.mirror     = nil       # defaults to "active_storage_mirror"

    # Using `Rails.application.config.active_record.belongs_to_required_by_default` in
    # `new_framework_defaults.rb` has no effect in Rails 5.0.x.
    # https://github.com/rails/rails/issues/23589
    # https://stackoverflow.com/questions/38850712/rails-5-belongs-to-required-by-default-doesnt-work
    # Not supported by `paper_trail` gem < 5.0
    # https://github.com/paper-trail-gem/paper_trail/issues/682
    config.active_record.belongs_to_required_by_default = false

    config.action_dispatch.trusted_proxies = %w(127.0.0.1/32).map { |proxy| IPAddr.new(proxy) }

    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time]
  end
end
