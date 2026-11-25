OpenAI.configure do |config|
  config.access_token = ENV['OPENAI_API_KEY']
  config.organization_id = ENV['OPENAI_ORGANIZATION_ID'] # Optional
  # config.uri_base = "https://oai.hconeai.com/" # Optional
  config.request_timeout = 240 # Optional
  config.log_errors = Rails.env.production? ? false : true
end
