module ApiLog
  class Db < ApplicationRecord
    self.abstract_class = true
    # to_sym is needed because passing a string to ActiveRecord::Base.establish_connection
    # for a configuration lookup is deprecated
    establish_connection "api_log_#{Rails.env}".to_sym
  end
end
