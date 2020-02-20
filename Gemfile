source 'https://rubygems.org'

# core
gem 'iso8601',      '0.12.1' # for dates and times
gem 'rails', '~> 5.1.7'
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '1.1.1'

# model related
gem 'paper_trail', '~> 8.1'
gem 'pg',                        '1.2.2'
# 1.8 is for Rails < 5.0
gem 'ransack', '~> 1.8'
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

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
gem 'kaminari'
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'select2-rails',    '3.5.9.3' # for autocomplete
gem 'cancancan'
gem 'devise', '~> 4.7'

gem 'grape'

# registry specfic
gem 'isikukood' # for EE-id validation
gem 'simpleidn', '0.0.9' # For punycode
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


gem 'epp', github: 'internetee/epp', branch: :master
gem 'epp-xml', '1.1.0', github: 'internetee/epp-xml'
gem 'que'
gem 'daemons-rails', '1.2.1'
gem 'que-web'
gem 'pdfkit'
gem 'jquery-ui-rails', '5.0.5'
gem 'airbrake'

gem 'company_register', github: 'internetee/company_register', branch: :master
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'lhv', github: 'internetee/lhv', branch: :master
gem 'domain_name'
gem 'haml', '~> 5.0'
gem 'wkhtmltopdf-binary'

gem 'directo', github: 'internetee/directo', branch: 'directo-api'

group :development do
  # deploy
  gem 'mina', '0.3.1' # for fast deployment
end

group :development, :test do
  gem 'pry', '0.10.1'
  gem 'sdoc',          '0.4.1'  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'railroady',     '1.3.0'  # to generate database diagrams
  gem 'autodoc'
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'minitest', '~> 5.14'
  gem 'simplecov', require: false
  gem 'webdrivers'
  gem 'webmock'
end
