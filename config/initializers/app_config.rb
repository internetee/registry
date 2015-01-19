APP_CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env]
Registry::Application.config.secret_token = APP_CONFIG['secret_key_base']
