source 'https://rubygems.org'

gem 'rails', '4.1.4'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease.
# Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Replacement for erb
gem 'haml-rails', '~> 0.5.3'

# For XML parsing
gem 'nokogiri', '~> 1.6.2.1'

# For punycode
gem 'simpleidn', '~> 0.0.5'

# for EE-id validation
gem 'isikukood'

# for using bootstrap
gem 'bootstrap-sass', '~> 3.2.0.1'

# for visual loader
gem 'nprogress-rails', '~> 0.1.3.1'

# for pagination
gem 'kaminari', '~> 0.16.1'

# for searching
gem 'ransack', '~> 1.3.0'

# for rights
gem 'cancan', '~> 1.6.10'

# for login
gem 'devise', '~> 3.3.0'

# for archiving
gem 'paper_trail', '~> 3.0.5'

# for select
gem 'selectize-rails', '~> 0.11.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# for settings
gem 'rails-settings-cached', '0.4.1'

# for scp to whois server
gem 'net-ssh'
gem 'net-scp'

group :development, :test do
  gem 'capybara', '~> 2.4.1'
  # For feature testing
  # gem 'capybara-webkit', '1.2.0' # Webkit driver didn't work with turbolinks
  gem 'phantomjs-binaries', '~> 1.9.2.4'
  gem 'poltergeist', '~> 1.5.1' # We are using PhantomJS instead
  gem 'phantomjs', '~> 1.9.7.1'

  # For cleaning db in feature and epp tests
  gem 'database_cleaner', '~> 1.3.0'

  # EPP client
  gem 'epp', '~> 1.4.0'

  # EPP XMLs
  gem 'epp-xml', '~> 0.7.0'

  # Replacement for fixtures
  gem 'fabrication', '~> 2.11.3'

  # Library to generate fake data
  gem 'faker', '~> 1.3.0'

  # For debugging
  gem 'pry', '~> 0.10.1'
  # gem 'pry-byebug', '~> 1.3.3'

  # Testing framework
  gem 'rspec-rails', '~> 3.0.2'

  # Additional matchers for RSpec
  gem 'shoulda-matchers', '~> 2.6.1', require: false

  # For unique IDs (used by the epp gem)
  gem 'uuidtools', '~> 2.1.4'

  # For code review
  gem 'simplecov', '~> 0.9.1', require: false
  gem 'rubycritic', '~> 1.1.1'

  # for finding database optimizations
  gem 'bullet', '~> 4.14.0'

  # for finding future vulnerable gems
  gem 'bundler-audit'

  # for security audit'
  gem 'brakeman', '~> 2.6.2', require: false

  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring'

  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'

  # run tests automatically
  gem 'guard', '~> 2.6.1'

  # rspec support for guard
  gem 'guard-rspec', '~> 4.3.1'
  gem 'rubocop', '~> 0.26.1'
  gem 'guard-rubocop', '~> 1.1.0'

  # for quick debugging
  gem 'web-console', '~> 2.0.0.beta4'

  # for finding dead routes and unused actions
  gem 'traceroute', '~> 0.4.0'

  # faster dev load time
  gem 'unicorn'
end
