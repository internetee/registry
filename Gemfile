source 'https://rubygems.org'

# core
gem 'rails',        '4.2.0'
gem 'iso8601',      '~> 0.8.2' # for dates and times
gem 'hashie_rails', '~> 0.0.1'

# model related
gem 'pg',                        '~> 0.18.0'
gem 'ransack',                   '~> 1.5.1' # for searching
gem 'paper_trail',               '~> 4.0.0.beta2' # archiving
gem 'rails-settings-cached',     '~> 0.4.1' # for settings
gem 'delayed_job_active_record', '~> 4.0.3' # delayed job

# html-xml
gem 'haml-rails', '~> 0.6.0' # haml for views
gem 'nokogiri',   '~> 1.6.2.1' # For XML parsing

# style
gem 'sass-rails',     '~> 5.0.1'   # sass style
gem 'bootstrap-sass', '~> 3.3.1.0' # bootstrap style

# js
gem 'uglifier',        '~> 2.6.1'  # minifies js
gem 'coffee-rails',    '~> 4.1.0'  # coffeescript support
gem 'turbolinks',      '~> 2.5.3'  # faster page load
gem 'jquery-rails',    '~> 4.0.3'  # jquery
gem 'selectize-rails', '~> 0.11.2' # include selectize.js for select
gem 'therubyracer',  platforms: :ruby

# view helpers
gem 'kaminari',        '~> 0.16.1'  # pagination
gem 'nprogress-rails', '~> 0.1.6.5' # visual loader

# rights
gem 'devise',    '~> 3.4.1' # authenitcation
gem 'cancancan', '~> 1.9.2' # autharization

# rest api
gem 'grape',    '~> 0.10.1'
gem 'jbuilder', '~> 2.2.6'  # json api

# registry specfic
gem 'simpleidn', '~> 0.0.5' # For punycode
gem 'isikukood' # for EE-id validation

# deploy
gem 'whenever', '~> 0.9.4', require: false
gem 'daemons',  '~> 1.1.9' # process delayed jobs

# monitors
gem 'newrelic_rpm', '~> 3.9.9.275'

# country listing
gem 'countries', '~> 0.10.0'

group :development do
  # dev tools
  gem 'spring',                '~> 1.2.0'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard',                 '~> 2.6.1' # run tests automatically
  gem 'guard-rspec',           '~> 4.3.1'
  gem 'guard-rails',           '~> 0.7.0' # run EPP server automatically
  gem 'rubocop',               '~> 0.26.1'
  gem 'guard-rubocop',         '~> 1.1.0'

  # improved errors
  gem 'better_errors',     '~> 2.0.0'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'traceroute',        '~> 0.4.0' # for finding dead routes and unused actions

  # deploy
  gem 'mina', '~> 0.3.1' # for fast deployment
end

group :development, :test do
  # test stack
  gem 'rspec-rails',        '~> 3.0.2'
  gem 'capybara',           '~> 2.4.1'
  gem 'phantomjs-binaries', '~> 1.9.2.4'
  gem 'poltergeist',        '~> 1.5.1'  # We are using PhantomJS instead
  gem 'phantomjs',          '~> 1.9.7.1'
  gem 'fabrication',        '~> 2.12.2' # Replacement for fixtures
  gem 'shoulda-matchers',   '~> 2.6.1', require: false # Additional matchers for RSpec
  gem 'launchy',            '~> 2.4.3' # for opening browser automatically

  # helper gems
  gem 'activerecord-import', '~> 0.6.0' # for inserting dummy data
  gem 'database_cleaner',    '~> 1.3.0' # For cleaning db in feature and epp tests
  gem 'faker',               '~> 1.3.0' # Library to generate fake data

  # EPP
  gem 'epp',       '~> 1.4.0'   # EPP client
  gem 'epp-xml',   '~> 0.10.4'  # EPP XMLs
  gem 'uuidtools', '~> 2.1.4' # For unique IDs (used by the epp gem)

  # debug
  gem 'pry', '~> 0.10.1'

  # code review
  gem 'simplecov',     '~> 0.9.1', require: false
  gem 'rubycritic',    '~> 1.1.1'
  gem 'bullet',        '~> 4.14.0' # for finding database optimizations
  gem 'bundler-audit', '~> 0.3.1'  # for finding future vulnerable gems
  gem 'brakeman',      '~> 2.6.2', require: false # for security audit'
  # tmp, otherwise conflics with breakman
  gem 'html2haml', github: 'haml/html2haml', ref: '6984f50bdbbd6291535027726a5697f28778ee8d'
  gem 'sdoc',          '~> 0.4.0'  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'railroady',     '~> 1.3.0'  # to generate database diagrams

  # dev tools
  gem 'unicorn'

  # for travis
  gem 'rake'
end
