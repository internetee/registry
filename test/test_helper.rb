if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.command_name 'test'
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'selenium/webdriver'
require 'support/rails5_assetions' # Remove once upgraded to Rails 5

Setting.address_processing = false
Setting.registry_country_code = 'US'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  ActiveRecord::Migration.check_pending!
  fixtures :all

  teardown do
    travel_back
  end
end

class ActionDispatch::IntegrationTest
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

class JavascriptIntegrationTest < ActionDispatch::IntegrationTest
  Capybara.register_driver(:chrome) do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new

    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,1400")

    Capybara::Selenium::Driver.new(Rails.application, browser: :chrome, options: options)
  end

  Capybara.register_server(:silent_puma) do |app, port, _host|
    require "rack/handler/puma"
    Rack::Handler::Puma.run(app, Port: port, Threads: "0:2", Silent: true)
  end

  def setup
    super

    Capybara.current_driver = :chrome
    Capybara.server = :silent_puma
  end
end
