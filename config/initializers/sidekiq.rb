require 'sidekiq/web' # Require at the top of the initializer

if ENV['redis_url'].present?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['redis_url'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['redis_url'] }
  end
end
