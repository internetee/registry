if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.command_name 'test'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/rails5_assertions' # Remove once upgraded to Rails 5

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
  include FactoryBot::Syntax::Methods

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
