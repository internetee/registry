# Use https only for accessing github
# https://github.com/bundler/bundler/pull/3447
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end if Bundler::VERSION < '2'

source 'https://rubygems.org'

# core
gem 'iso8601',      '0.8.6' # for dates and times
gem 'rails',        '4.2.11.1' # when update, all initializers eis_custom files needs check/update
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '1.1.1'

# model related
gem 'pg',                        '0.19.0'
# 1.8 is for Rails < 5.0
gem 'ransack', '~> 1.8'
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696
gem 'paper_trail', '~> 4.0'

# 0.7.3 is the latest for Rails 4.2, however, it is absent on Rubygems server
# https://github.com/huacnlee/rails-settings-cached/issues/165
gem 'rails-settings-cached', '0.7.2'
gem 'nokogiri'

# style
gem 'bootstrap-sass', '~> 3.4'
gem 'sass-rails',     '5.0.6'   # sass style
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'selectize-rails', '0.12.1' # include selectize.js for select

# view helpers
gem 'kaminari',         '0.16.3'  # pagination
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'select2-rails',    '3.5.9.3' # for autocomplete
gem 'cancancan'
gem 'devise', '~> 4.7'

gem 'grape'

# registry specfic
gem 'isikukood' # for EE-id validation
gem 'simpleidn', '0.0.7' # For punycode
gem 'money-rails'
gem 'data_migrate'
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
gem 'pdfkit'
gem 'jquery-ui-rails', '5.0.5'
gem 'active_model-errors_details' # Backport from Rails 5, https://github.com/rails/rails/pull/18322
gem 'airbrake'

gem 'company_register', github: 'internetee/company_register', branch: :master
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'lhv', github: 'internetee/lhv', tag: 'v0.1.0'
gem 'domain_name'
gem 'haml'
gem 'wkhtmltopdf-binary'

group :development do
  # deploy
  gem 'mina', '0.3.1' # for fast deployment
end

group :development, :test do
  gem 'capybara'
  gem 'selenium-webdriver'

  # debug
  gem 'pry', '0.10.1'

  gem 'bullet',        '4.14.7' # for finding database optimizations
  gem 'sdoc',          '0.4.1'  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'railroady',     '1.3.0'  # to generate database diagrams
  gem 'autodoc'
  gem 'puma'
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'webmock'
end
