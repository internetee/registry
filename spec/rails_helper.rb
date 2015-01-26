# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'

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

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:all) do
    ActiveRecord::Base.establish_connection :api_log_test
    DatabaseCleaner.strategy = :deletion
    ActiveRecord::Base.establish_connection :test
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, epp: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:all, epp: true) do
    ActiveRecord::Base.establish_connection :api_log_test
    DatabaseCleaner.clean

    ActiveRecord::Base.establish_connection :test
    DatabaseCleaner.clean
  end

  config.after(:all, epp: true) do
    ActiveRecord::Base.establish_connection :api_log_test
    DatabaseCleaner.clean

    ActiveRecord::Base.establish_connection :test
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :request) do
    DatabaseCleaner.strategy = :truncation
  end

  # config.before(:each) do
  #   ActiveRecord::Base.establish_connection :api_log_test
  #   DatabaseCleaner.start

  #   ActiveRecord::Base.establish_connection :test
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   ActiveRecord::Base.establish_connection :api_log_test
  #   DatabaseCleaner.clean

  #   ActiveRecord::Base.establish_connection :test
  #   DatabaseCleaner.clean
  # end

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
    c.syntax = :expect
  end
end
