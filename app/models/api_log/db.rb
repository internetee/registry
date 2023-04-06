module ApiLog
  class Db < ApplicationRecord
    self.abstract_class = true
    # to_sym is needed because passing a string to ActiveRecord::Base.establish_connection
    # for a configuration lookup is deprecated
    establish_connection "api_log_#{Rails.env}".to_sym

    def self.ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def self.ransackable_attributes(*)
      authorizable_ransackable_attributes
    end
  end
end
