NewRelic::Agent.config[:app_name] = "#{ENV['new_relic_app_name']} - #{Rails.env}" if ENV['new_relic_app_name'].present?
