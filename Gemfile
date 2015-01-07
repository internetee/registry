source 'https://rubygems.org'

# core
gem 'rails',        '4.1.4'    # '4.2.0'
gem 'iso8601',      '~> 0.8.2' # for dates and times
gem 'hashie_rails', '~> 0.0.1'

# model related
gem 'pg',                        '~> 0.18.0'
gem 'ransack',                   '~> 1.3.0' # '1.5.1' # for searching
gem 'paper_trail',               '~> 3.0.5' # '3.0.6' # archiving
gem 'rails-settings-cached',     '~> 0.4.1' # for settings
gem 'delayed_job_active_record', '~> 4.0.2' # '4.0.3' # delayed job

# html-xml
gem 'haml-rails', '~> 0.5.3' # '0.6.0' haml for views
gem 'nokogiri', '~> 1.6.2.1' # For XML parsing

# style
gem 'sass-rails', '~> 4.0.3'       # '5.0.0'   # sass style
gem 'bootstrap-sass', '~> 3.2.0.1' # '3.3.1.0' # bootstrap style

# js
gem 'uglifier', '>= 1.3.0'         # '2.6.1' # minifies js
gem 'coffee-rails', '~> 4.0.0'     # '4.1.0' # coffeescript support
gem 'turbolinks'                   # '2.5.3' # faster page load
gem 'jquery-rails'                 # '4.0.3' # jquery
gem 'jbuilder', '~> 2.0'           # '2.2.6' # json api
gem 'selectize-rails', '~> 0.11.0' # '0.11.2' # include selectize.js for select

# view helpers
gem 'kaminari', '~> 0.16.1'         # pagination
gem 'nprogress-rails', '~> 0.1.3.1' # '0.1.6.5' # visual loader

# rest api
gem 'grape', '~> 0.10.1'

# rights
gem 'devise',    '~> 3.3.0' # '3.4.0' # authenitcation
gem 'cancancan', '~> 1.9.2' # autharization

# registry specfic
gem 'simpleidn', '~> 0.0.5' # For punycode
gem 'isikukood' # for EE-id validation

# deploy
gem 'whenever', '~> 0.9.4', require: false
gem 'daemons'  '~> 1.1.9' # process delayed jobs

group :development, :test do
  # for inserting dummy data
  gem 'activerecord-import', '~> 0.6.0'

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
  gem 'epp-xml', '~> 0.10.3'

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

  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'

  # faster dev load time
  gem 'unicorn'

  # for opening browser automatically
  gem 'launchy', '~> 2.4.3'
end

group :development do
  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.2'

  # for fast deployment
  gem 'mina', '~> 0.3.1'

  # for finding dead routes and unused actions
  gem 'traceroute', '~> 0.4.0'

  # for improved errors
  gem 'better_errors', '~> 2.0.0'
  gem 'binding_of_caller', '~> 0.7.2'

  # run tests automatically
  gem 'guard', '~> 2.6.1'

  # rspec support for guard
  gem 'guard-rspec', '~> 4.3.1'
  gem 'rubocop', '~> 0.26.1'
  gem 'guard-rubocop', '~> 1.1.0'

  # to generate database diagrams
  gem 'railroady'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer',  platforms: :ruby
end
