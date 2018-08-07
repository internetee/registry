require 'test_helper'

require 'database_cleaner'
require 'selenium/webdriver'

ApplicationSystemTestCase = Class.new(ApplicationIntegrationTest)

class JavaScriptApplicationSystemTestCase < ApplicationSystemTestCase
  self.use_transactional_fixtures = false
  DatabaseCleaner.strategy = :truncation

  Capybara.register_driver(:chrome) do |_app|
    options = ::Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1400,1400')

    Capybara::Selenium::Driver.new(Rails.application, browser: :chrome, options: options)
  end

  Capybara.register_server(:silent_puma) do |app, port, _host|
    require 'rack/handler/puma'
    Rack::Handler::Puma.run(app, Port: port, Threads: '0:2', Silent: true)
  end

  def setup
    DatabaseCleaner.start

    super

    Capybara.current_driver = :chrome
    Capybara.server = :silent_puma
  end

  def teardown
    super

    DatabaseCleaner.clean
  end
end
