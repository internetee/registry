ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'capybara/minitest'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  ActiveRecord::Migration.check_pending!
  fixtures :all
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include AbstractController::Translation

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
