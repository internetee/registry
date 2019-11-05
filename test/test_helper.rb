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
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/rails5_assertions' # Remove once upgraded to Rails 5
require 'support/assertions/epp_assertions'

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
  ActiveRecord::Migration.check_pending!
  fixtures :all

  teardown do
    travel_back
  end
end

# Allows testing OPTIONS request just like GET or POST
module ActionDispatch::Integration::RequestHelpers
  def options(path, parameters = nil, headers_or_env = nil)
    process :options, path, parameters, headers_or_env
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
