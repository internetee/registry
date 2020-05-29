if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/app/models/version/'
    add_filter '/lib/action_controller/'
    add_filter '/lib/core_monkey_patches/'
    add_filter '/lib/daemons/'
    add_filter '/lib/gem_monkey_patches/'
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/assertions/epp_assertions'


# `bin/rails test` is not the same as `bin/rake test`.
# All tasks will be loaded (and executed) twice when using the former without `Rake::Task.clear`.
# https://github.com/rails/rails/issues/28786
require 'rake'
Rake::Task.clear
Rails.application.load_tasks

Setting.address_processing = false
Setting.registry_country_code = 'US'

class CompanyRegisterClientStub
  Company = Struct.new(:registration_number)

  def representation_rights(citizen_personal_code:, citizen_country_code:)
    [Company.new('1234567')]
  end
end

CompanyRegister::Client = CompanyRegisterClientStub

EInvoice.provider = EInvoice::Providers::TestProvider.new

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  ActiveRecord::Migration.check_pending!
  fixtures :all

  teardown do
    travel_back
  end
end

class ApplicationIntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include AbstractController::Translation
  include Devise::Test::IntegrationHelpers

  teardown do
    WebMock.reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class EppTestCase < ActionDispatch::IntegrationTest
  include Assertions::EppAssertions
end
