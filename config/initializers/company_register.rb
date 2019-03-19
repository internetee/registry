CompanyRegister.configure do |config|
  config.username = ENV['company_register_username']
  config.password = ENV['company_register_password']
  config.cache_period = ENV['company_register_cache_period_days'].to_i.days
  config.test_mode = ENV['company_register_test_mode'] == 'true'
end