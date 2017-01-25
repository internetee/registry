ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'
require 'money-rails/test_helpers'
require 'support/requests/session_helpers'
require 'support/requests/epp_helpers'
require 'support/features/session_helpers'

if ENV['ROBOT']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'support/matchers/alias_attribute'
require 'support/matchers/active_job'
require 'support/matchers/epp/code'
require 'support/capybara'
require 'support/factory_girl'
require 'support/database_cleaner'
require 'support/paper_trail'
require 'support/settings'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Requests::SessionHelpers, type: :request
  config.include Features::SessionHelpers, type: :feature
  config.include AbstractController::Translation, type: :feature

  config.include Requests::EPPHelpers, epp: true

  config.define_derived_metadata(file_path: %r[/spec/features/]) do |metadata|
    metadata[:db] = true if metadata[:db].nil?
  end

  config.define_derived_metadata(file_path: %r[/spec/models/]) do |metadata|
    metadata[:db] = true if metadata[:db].nil?
  end

  config.define_derived_metadata(file_path: %r[/spec/presenters/]) do |metadata|
    metadata[:type] = :presenter
  end

  config.define_derived_metadata(file_path: %r[/spec/requests/]) do |metadata|
    metadata[:db] = true if metadata[:db].nil?
  end

  config.define_derived_metadata(file_path: %r[/spec/requests/epp/]) do |metadata|
    metadata[:epp] = true if metadata[:epp].nil?
  end

  config.define_derived_metadata(file_path: %r[/spec/api/]) do |metadata|
    metadata[:type] = :request
  end

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
