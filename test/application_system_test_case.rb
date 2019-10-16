require 'test_helper'

require 'database_cleaner'
require 'selenium/webdriver'

class ApplicationSystemTestCase < ActionDispatch::IntegrationTest
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

class JavaScriptApplicationSystemTestCase < ApplicationSystemTestCase
  self.use_transactional_fixtures = false
  DatabaseCleaner.strategy = :truncation

  Capybara.register_driver(:chrome) do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1400,1400')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.server = :puma, { Silent: true }

  def setup
    DatabaseCleaner.start

    super

    Capybara.current_driver = :chrome
  end

  def teardown
    super

    DatabaseCleaner.clean
  end
end
