Apipie.configure do |config|
  config.app_name = "Estonian Internet Foundation's REST EPP"
  config.validate = true
  config.translate = false
  config.api_base_url = "/api"
  config.doc_base_url = "/apipie"
  config.swagger_content_type_input = :json
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
