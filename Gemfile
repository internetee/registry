# Use https only for accessing github
# https://github.com/bundler/bundler/pull/3447
if Bundler::VERSION < '2'
  git_source(:github) do |repo_name|
    repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
    "https://github.com/#{repo_name}.git"
  end
end

source 'https://rubygems.org'

# core
gem 'iso8601',      '0.8.6' # for dates and times
gem 'rails',        '4.2.11.1' # when update, all initializers eis_custom files needs check/update
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '1.1.1'

# model related
gem 'paper_trail', '~> 4.0'
gem 'pg',                        '0.19.0'
gem 'rails-settings-cached',     '0.4.1' # for settings
gem 'ransack',                   '1.5.1' # for searching
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

# html-xml
gem 'haml-rails', '0.9.0' # haml for views
gem 'nokogiri'

# style
gem 'bootstrap-sass', '~> 3.4'
gem 'sass-rails',     '5.0.6' # sass style

# js

gem 'coffee-rails',    '4.1.0'  # coffeescript support
gem 'jquery-rails',    '4.0.4'  # jquery
gem 'selectize-rails', '0.12.1' # include selectize.js for select

# view helpers
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'kaminari',         '0.16.3'  # pagination
gem 'liquid',           '3.0.6'   # for email templates
gem 'select2-rails',    '3.5.9.3' # for autocomplete

# rights
gem 'cancancan', '1.11.0' # autharization
gem 'devise', '~> 4.0'

gem 'grape'
gem 'jbuilder', '2.2.16'  # json api

# registry specfic
gem 'isikukood' # for EE-id validation
gem 'money-rails'
gem 'simpleidn', '0.0.7' # For punycode

# deploy
gem 'data_migrate',
    github: 'internetee/data-migrate',
    ref: '35d22b09ff37a4e9d61ab326ad5d8eb0edf1fc81'
gem 'whenever', '0.9.4', require: false

# country listing
gem 'countries', require: 'countries/global'

# id + mid login
# gem 'digidoc_client', '0.3.0'
gem 'digidoc_client',
    github: 'tarmotalu/digidoc_client',
    ref: '1645e83a5a548addce383f75703b0275c5310c32'

gem 'epp', '1.5.0', github: 'internetee/epp'
gem 'epp-xml', '1.1.0', github: 'internetee/epp-xml'
gem 'uuidtools', '2.1.5' # For unique IDs (used by the epp gem)

# que
gem 'daemons-rails', '1.2.1'
gem 'que',           '0.10.0'
gem 'que-web',       '0.4.0'

# for importing legacy db
gem 'activerecord-import', '0.7.0' # for inserting dummy data

# for generating pdf
gem 'active_model-errors_details' # Backport from Rails 5, https://github.com/rails/rails/pull/18322
gem 'airbrake'
gem 'jquery-ui-rails', '5.0.5'
gem 'pdfkit', '0.6.2'

gem 'company_register', github: 'internetee/company_register', branch: :master

group :development do
  # deploy
  gem 'mina', '0.3.1' # for fast deployment
end

group :development, :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.6'
  gem 'selenium-webdriver'

  # debug
  gem 'pry', '0.10.1'

  gem 'autodoc'
  gem 'bullet', '4.14.7' # for finding database optimizations
  gem 'html2haml', '2.1.0'
  gem 'puma'
  gem 'railroady',     '1.3.0'  # to generate database diagrams
  gem 'sdoc',          '0.4.1'  # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'webmock'
end
