module ApiLog
  class Db < ApplicationRecord
    self.abstract_class = true

    establish_connection "api_log_#{Rails.env}".to_sym

    def self.ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def self.ransackable_attributes(*)
      authorizable_ransackable_attributes
    end
  end
end
