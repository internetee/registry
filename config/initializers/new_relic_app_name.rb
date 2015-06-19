if !Rails.env.test? && ENV['new_relic_app_name'].present?
  require 'newrelic'
  NewRelic::Agent.config[:app_name] = "#{ENV['new_relic_app_name']} - #{Rails.env}"
end
