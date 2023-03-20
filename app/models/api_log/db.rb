module ApiLog
  class Db < ApplicationRecord
    self.abstract_class = true
    # to_sym is needed because passing a string to ActiveRecord::Base.establish_connection
    # for a configuration lookup is deprecated
    establish_connection "api_log_#{Rails.env}".to_sym

    def self.ransackable_associations(auth_object = nil)
      super
    end

    def self.ransackable_attributes(auth_object = nil)
      super
    end
  end
end
