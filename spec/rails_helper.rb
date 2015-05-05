# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'
PaperTrail.whodunnit = 'autotest'

if ENV['ROBOT']
  require 'simplecov'
  SimpleCov.start 'rails'
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# create general settings
def create_settings
  Setting.ds_algorithm = 2
  Setting.ds_data_allowed = true
  Setting.ds_data_with_key_allowed = true
  Setting.key_data_allowed = true

  Setting.dnskeys_min_count = 0
  Setting.dnskeys_max_count = 9
  Setting.ns_min_count = 2
  Setting.ns_max_count = 11

  Setting.transfer_wait_time = 0

  Setting.admin_contacts_min_count = 1
  Setting.admin_contacts_max_count = 10
  Setting.tech_contacts_min_count = 0
  Setting.tech_contacts_max_count = 10

  Setting.client_side_status_editing_enabled = true

  @fixed_registrar = 
    Registrar.find_by_name('fixed registrar') || 
    Fabricate(:registrar, name: 'fixed registrar', code: 'FIXED')
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveRecord::Base.establish_connection :api_log_test
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = nil

    ActiveRecord::Base.establish_connection :test
  end

  config.before(:all) do
    DatabaseCleaner.clean_with(:truncation)
    create_settings
  end

  config.before(:all, epp: true) do
    DatabaseCleaner.strategy = nil
    create_settings
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    create_settings
  end

  config.before(:each, type: :request) do
    DatabaseCleaner.strategy = :truncation
    create_settings
  end

  config.before(:each, type: :model) do
    create_settings
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each, type: :model) do
    DatabaseCleaner.clean
  end

  Capybara.javascript_driver = :poltergeist

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  Autodoc.configuration.path = 'doc/repp'
  Autodoc.configuration.suppressed_request_header = ['Host']
  Autodoc.configuration.suppressed_response_header = ['ETag', 'X-Request-Id', 'X-Runtime']
  Autodoc.configuration.template = File.read('spec/requests/repp_doc_template.md.erb')
end

