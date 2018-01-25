# Use https only for accessing github
# https://github.com/bundler/bundler/pull/3447
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end if Bundler::VERSION < '2'

source 'https://rubygems.org'

# core

gem 'SyslogLogger', '2.0', require: 'syslog/logger'
gem 'iso8601',      '0.8.6' # for dates and times
gem 'rails',        '4.2.7.1' # when update, all initializers eis_custom files needs check/update
gem 'rest-client'

# load env
gem 'figaro', '1.1.1'

# model related
gem 'pg',                        '0.19.0'
gem 'ransack',                   '1.5.1' # for searching
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

# with polymorphic fix
gem 'paper_trail',
  github: 'airblade/paper_trail',
  ref: 'a453811226ec4ea59753ba6b827e390ced2fc140'
# NB! if this gets upgraded, ensure Setting.reload_settings! still works correctly
gem 'rails-settings-cached',     '0.4.1' # for settings

# html-xml
gem 'haml-rails', '0.9.0' # haml for views
gem 'nokogiri'

# style
gem 'bootstrap-sass', '3.3.5.1' # bootstrap style
gem 'sass-rails',     '5.0.6'   # sass style

# js

gem 'coffee-rails',    '4.1.0'  # coffeescript support
gem 'jquery-rails',    '4.0.4'  # jquery
gem 'selectize-rails', '0.12.1' # include selectize.js for select
gem 'jquery-validation-rails', '1.13.1' # validate on client side

# view helpers
gem 'kaminari',         '0.16.3'  # pagination
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'html5_validators', '1.2.2'   # model requements now automatically on html form
gem 'select2-rails',    '3.5.9.3' # for autocomplete
gem 'liquid',           '3.0.6'   # for email templates

# rights
gem 'cancancan', '1.11.0' # autharization
gem 'devise',    '3.5.4'  # authenitcation

# rest api
gem 'grape',    '0.12.0'
gem 'hashie-forbidden_attributes', '0.1.1' # For grape, https://github.com/ruby-grape/grape/tree/v0.12.0#rails
gem 'jbuilder', '2.2.16'  # json api

# registry specfic
gem 'isikukood' # for EE-id validation
gem 'simpleidn', '0.0.7' # For punycode
gem 'money-rails'

# deploy
gem 'data_migrate',
  github: 'internetee/data-migrate',
  ref: '35d22b09ff37a4e9d61ab326ad5d8eb0edf1fc81'
gem 'whenever', '0.9.4', require: false

# country listing
gem 'countries', :require => 'countries/global'

# id + mid login
# gem 'digidoc_client', '0.3.0'
gem 'digidoc_client',
    github: 'tarmotalu/digidoc_client',
    ref: '1645e83a5a548addce383f75703b0275c5310c32'


gem 'epp', '1.5.0', github: 'internetee/epp'
gem 'epp-xml', '1.1.0', github: 'internetee/epp-xml'
gem 'uuidtools', '2.1.5' # For unique IDs (used by the epp gem)

# que
gem 'que',           '0.10.0'
gem 'daemons-rails', '1.2.1'
gem 'que-web',       '0.4.0'
gem 'que_mailer',
    github: 'prehnRA/que-mailer',
    branch: 'master'

# for importing legacy db
gem 'activerecord-import', '0.7.0' # for inserting dummy data

# for generating pdf
gem 'pdfkit', '0.6.2'
gem 'jquery-ui-rails', '5.0.5'
gem 'active_model-errors_details' # Backport from Rails 5, https://github.com/rails/rails/pull/18322

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rubocop'

  # deploy
  gem 'mina', '0.3.1' # for fast deployment
  gem 'puma'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'rspec-rails', '~> 3.6'
  gem 'poltergeist'

  # debug
  gem 'pry', '0.10.1'

  gem 'bullet',        '4.14.7' # for finding database optimizations
  gem 'bundler-audit'
  gem 'brakeman',      '3.6.1', require: false # for security audit'
  # tmp, otherwise conflics with breakman
  # gem 'html2haml', github: 'haml/html2haml', ref: '6984f50bdbbd6291535027726a5697f28778ee8d'
  gem 'html2haml',     '2.1.0'
  gem 'sdoc',          '0.4.1'  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'railroady',     '1.3.0'  # to generate database diagrams
  gem 'autodoc'
end

group :staging do
  gem 'airbrake'
end

group :test do
  gem 'database_cleaner'
  gem 'codeclimate-test-reporter', "~> 1.0.0"
  gem 'simplecov'
  gem 'webmock'
end
