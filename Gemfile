# Use https only for accessing github
# https://github.com/bundler/bundler/pull/3447
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end if Bundler::VERSION < '2'

source 'https://rubygems.org'

# core

gem 'SyslogLogger', '2.0', require: 'syslog/logger'
gem 'hashie-forbidden_attributes', '0.1.1'
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
gem 'nokogiri', '1.7.1' # For XML parsing

# style

gem 'bootstrap-sass', '3.3.5.1' # bootstrap style
gem 'sass-rails',     '5.0.6'   # sass style

# js

gem 'coffee-rails',    '4.1.0'  # coffeescript support
gem 'uglifier',        '2.7.2'  # minifies js
gem 'jquery-rails',    '4.0.4'  # jquery
gem 'turbolinks',      '2.5.3'  # faster page load
gem 'selectize-rails', '0.12.1' # include selectize.js for select
gem 'jquery-validation-rails', '1.13.1' # validate on client side
gem 'therubyracer',    '0.12.2', platforms: :ruby

# view helpers
gem 'kaminari',         '0.16.3'  # pagination
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'html5_validators', '1.2.2'   # model requements now automatically on html form
gem 'nprogress-rails',  '0.1.6.7' # visual loader
gem 'select2-rails',    '3.5.9.3' # for autocomplete
gem 'bootstrap-datepicker-rails', '1.3.1.1' # datepicker
gem 'liquid',           '3.0.6'   # for email templates

# rights
gem 'cancancan', '1.11.0' # autharization
gem 'devise',    '3.5.4'  # authenitcation

# rest api
gem 'grape',    '0.12.0'
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

# cloning activerecord objects
gem 'deep_cloneable', '2.1.1'

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

# for datepicker
gem 'jquery-ui-rails', '5.0.5'

# codeclimate


group :development do
  gem 'guard',                 '2.12.9' # run tests automatically
  gem 'spring',                '1.3.6'
  gem 'spring-commands-rspec', '1.0.4'
  gem 'guard-rails',           '0.7.1' # run EPP server automatically

  gem 'guard-rspec',           '4.5.2'
  gem 'guard-rubocop',         '1.2.0'
  gem 'rubocop',               '0.48.1'

  # deploy
  gem 'mina', '0.3.1' # for fast deployment
  gem 'puma'
end

group :development, :test do
  # test stack
  gem 'rspec-rails',        '3.5.2'
  gem 'capybara',           '2.4.4'
  gem 'rspec-rails',        '3.5.2' 
  gem 'fabrication',        '2.13.2' # Replacement for fixtures
  gem 'phantomjs-binaries', '1.9.2.4' 
  gem 'phantomjs',          '1.9.8.0'
  gem 'poltergeist',        '1.6.0'  # We are using PhantomJS instead
  gem 'launchy',            '2.4.3' # for opening browser automatically

  # debug
  gem 'pry', '0.10.1'

  # code review

  gem 'rubycritic',    '3.2.0'
  gem 'bullet',        '4.14.7' # for finding database optimizations
  gem 'bundler-audit'
#  gem 'simplecov',     '0.10.0', require: false
  gem 'brakeman',      '3.6.1', require: false # for security audit'
  # tmp, otherwise conflics with breakman
  # gem 'html2haml', github: 'haml/html2haml', ref: '6984f50bdbbd6291535027726a5697f28778ee8d'
  gem 'html2haml',     '2.1.0'
  gem 'sdoc',          '0.4.1'  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'railroady',     '1.3.0'  # to generate database diagrams

  # dev tools
  gem 'unicorn'
  gem 'autodoc'
end

group :staging do
  gem 'airbrake'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails' 
  gem 'codeclimate-test-reporter', "~> 1.0.0"
  gem 'simplecov'
  gem 'webmock'
end
