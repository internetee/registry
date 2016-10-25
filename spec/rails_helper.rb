ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'
require 'money-rails/test_helpers'

if ENV['ROBOT']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'support/matchers/alias_attribute'
require 'support/matchers/active_job'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/request'
require 'support/paper_trail'

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
end

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include ActiveSupport::Testing::TimeHelpers

  config.define_derived_metadata(file_path: %r{/spec/presenters/}) do |metadata|
    metadata[:type] = :presenter
    metadata[:db] = false
  end

  config.use_transactional_fixtures = false

  config.before(:all) do
    create_settings
  end

  config.before(:all, epp: true) do
    create_settings
  end

  config.before(:each, js: true) do
    create_settings
  end

  config.before(:each, type: :request) do
    create_settings
  end

  config.before(:each, type: :model) do
    create_settings
  end

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
