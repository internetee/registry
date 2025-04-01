OpenAI.configure do |config|
  config.access_token = ENV['openai_access_token']
  config.organization_id = ENV['openai_organization_id'] # Optional
  # config.uri_base = "https://oai.hconeai.com/" # Optional
  config.request_timeout = 240 # Optional
  config.log_errors = Rails.env.production? ? false : true
end
