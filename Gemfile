source 'https://rubygems.org'

# core
gem 'bootsnap', '>= 1.1.0', require: false
gem 'iso8601', '0.12.1' # for dates and times
gem 'rails', '~> 6.0'
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '1.1.1'

# model related
gem 'activerecord-import'
gem 'paper_trail', '~> 10.3'
gem 'pg',                        '1.2.2'
# 1.8 is for Rails < 5.0
gem 'ransack', '~> 2.3'
gem 'truemail', '~> 1.7' # validates email by regexp, mail server existence and address existence
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

# 0.7.3 is the latest for Rails 4.2, however, it is absent on Rubygems server
# https://github.com/huacnlee/rails-settings-cached/issues/165
gem 'nokogiri'

# style
gem 'bootstrap-sass', '~> 3.4'
gem 'coffee-rails', '>= 5.0'
gem 'jquery-rails'
gem 'selectize-rails', '0.12.1' # include selectize.js for select
gem 'kaminari'
gem 'coderay',          '1.1.0'   # xml console visualize
gem 'sass-rails'
gem 'select2-rails',    '3.5.9.3' # for autocomplete
gem 'cancancan'
gem 'devise', '~> 4.7'

gem 'grape'

# registry specfic
gem 'data_migrate', '~> 6.1'
gem 'isikukood' # for EE-id validation
gem 'simpleidn', '0.1.1' # For punycode
gem 'money-rails'
gem 'whenever', '0.9.4', require: false

# country listing
gem 'countries', :require => 'countries/global'

# id + mid login
# gem 'digidoc_client', '0.3.0'
gem 'digidoc_client',
    github: 'tarmotalu/digidoc_client',
    ref: '1645e83a5a548addce383f75703b0275c5310c32'

# TARA
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-tara', github: 'internetee/omniauth-tara'


gem 'epp', github: 'internetee/epp', branch: :master
gem 'epp-xml', '1.1.0', github: 'internetee/epp-xml'
gem 'que'
gem 'daemons-rails', '1.2.1'
gem 'que-web'
gem 'pdfkit'
gem 'jquery-ui-rails', '5.0.5'
gem 'airbrake'

gem 'company_register', github: 'internetee/company_register',
                        branch: '1708-registrant-companies-endpoint'
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'lhv', github: 'internetee/lhv', branch: 'master'
gem 'domain_name'
gem 'haml', '~> 5.0'
gem 'wkhtmltopdf-binary', '~> 0.12.5.1'

gem 'directo', github: 'internetee/directo', branch: 'master'

group :development do
  # deploy
  gem 'listen', '3.2.1'
  gem 'mina', '0.3.1' # for fast deployment
end

group :development, :test do
  gem 'pry', '0.10.1'
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'minitest', '~> 5.14'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
  gem 'webdrivers'
  gem 'webmock'
end
