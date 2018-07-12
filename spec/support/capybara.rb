require_relative 'macros/capybara'

RSpec.configure do |config|
  config.include CapybaraViewMacros, type: :view
  config.include CapybaraViewMacros, type: :presenter
end
