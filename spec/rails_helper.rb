ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'
require 'money-rails/test_helpers'
require 'support/features/session_helpers'

if ENV['ROBOT']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'support/matchers/alias_attribute'
require 'support/matchers/active_job'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/paper_trail'
require 'support/settings'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Features::SessionHelpers, type: :feature
  config.include AbstractController::Translation, type: :feature

  config.define_derived_metadata(file_path: %r{/spec/presenters/}) do |metadata|
    metadata[:type] = :presenter
    metadata[:db] = false
  end

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
