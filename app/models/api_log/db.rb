module ApiLog
  class Db < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "api_log_#{Rails.env}".to_sym
  end
end
