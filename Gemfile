source 'https://rubygems.org'

gem 'rails', '4.1.1'

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

group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer',  platforms: :ruby
end

group :development do
  # faster dev load time
  gem 'unicorn'

  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring'

  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

group :development, :test do
  # For cleaning db in feature and epp tests
  gem 'database_cleaner', '~> 1.3.0'

  # EPP client
  gem 'epp', '~> 1.4.0'

  # Replacement for fixtures
  gem 'fabrication', '~> 2.11.3'

  # Library to generate fake data
  gem 'faker', '~> 1.3.0'

  # For debugging
  gem 'pry'
  gem 'pry-byebug'

  # Testing framework
  gem 'rspec-rails', '~> 3.0.1'

  # Additional matchers for RSpec
  gem 'shoulda-matchers', '~> 2.6.1', require: false

  # For unique IDs (used by the epp gem)
  gem 'uuidtools', '~> 2.1.4'
end
