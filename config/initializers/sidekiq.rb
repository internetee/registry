require 'sidekiq/web' # Require at the top of the initializer

Sidekiq::Web.set :session_secret, Rails.application.secret_key_base
