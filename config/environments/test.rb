Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  ActiveSupport::Deprecation.silenced = true

  # For rails-settings-cached conflict
  config.cache_store = :file_store, 'tmp/cache_test'

  config.action_view.raise_on_missing_translations = true

  # The available log levels are: :debug, :info, :warn, :error, :fatal, and :unknown,
  # corresponding to the log level numbers from 0 up to 5 respectively
  config.log_level = :debug

  # for finding database optimization
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.raise = true # raise an error if n+1 query occurs
    Bullet.unused_eager_loading_enable = false

    # Currenty hard to fix, it is triggered by Epp::Domain.new_from_epp for create request
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Contact', association: :registrar

    # when domain updates, then we need to update all contact linked status,
    # somehow it triggers bullet counter cache for versions,
    # there was no output indicating each version where fetched or counted
    # thus needs more investigation
    Bullet.add_whitelist type: :counter_cache, class_name: 'Contact', association: :versions
  end

  config.active_job.queue_adapter = :test
  config.logger = ActiveSupport::Logger.new(nil)
end

# In this mode, any jobs you queue will be run in the same thread, synchronously
# (that is, MyJob.enqueue runs the job and won't return until it's completed).
# This makes your application's behavior easier to test
Que.mode = :sync
