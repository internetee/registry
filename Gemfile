source 'https://rubygems.org'

# core
gem 'active_interaction', '~> 4.0'
gem 'apipie-rails', '~> 0.5.19'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'iso8601', '0.13.0' # for dates and times
gem 'mimemagic', '0.4.3'
gem 'mime-types-data'
gem 'puma'
gem 'rails', '~> 6.1.4'
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '~> 1.2'

# model related
gem 'paper_trail', '~> 12.1'
gem 'pg',                        '1.4.1'
# 1.8 is for Rails < 5.0
gem 'ransack', '~> 2.6.0'
gem 'truemail', '~> 2.4' # validates email by regexp, mail server existence and address existence
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

# 0.7.3 is the latest for Rails 4.2, however, it is absent on Rubygems server
# https://github.com/huacnlee/rails-settings-cached/issues/165
gem 'nokogiri', '~> 1.13.0'

# style
gem 'bootstrap-sass', '~> 3.4'
gem 'cancancan'
gem 'coderay',          '1.1.3'   # xml console visualize
gem 'coffee-rails', '>= 5.0'
gem 'devise', '~> 4.8'
gem 'jquery-rails'
gem 'kaminari'
gem 'sass-rails'
gem 'select2-rails',    '4.0.13' # for autocomplete
gem 'selectize-rails', '0.12.6' # include selectize.js for select

# registry specfic
gem 'data_migrate', '~> 8.0'
gem 'dnsruby', '~> 1.61'
gem 'isikukood' # for EE-id validation
gem 'money-rails'
gem 'simpleidn', '0.2.1' # For punycode
gem 'whenever', '1.0.0', require: false

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


gem 'airbrake'
gem 'daemons-rails', '1.2.1'
gem 'epp', github: 'internetee/epp', branch: :master
gem 'epp-xml', '1.2.0', github: 'internetee/epp-xml', branch: :master
gem 'jquery-ui-rails', '6.0.1'
gem 'pdfkit'
gem 'que'
gem 'que-web'
gem 'sidekiq', '>= 6.4.1'

gem 'company_register', github: 'internetee/company_register',
                        branch: 'master'
gem 'domain_name'
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'haml', '~> 5.2'
gem 'lhv', github: 'internetee/lhv', branch: 'master'
gem 'rexml'
gem 'wkhtmltopdf-binary', '~> 0.12.5.1'

gem 'directo', github: 'internetee/directo', branch: 'master'

group :development, :test do
  gem 'pry', '0.14.1'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'minitest', '~> 5.14'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
  gem 'spy'
  gem 'webdrivers'
  gem 'webmock'
end

gem 'aws-sdk-sesv2', '~> 1.19'

# profiles
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'newrelic_rpm'
gem 'newrelic-infinite_tracing'

# token
gem 'jwt'
