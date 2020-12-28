module Whois
  class UpdateRecord < ActiveInteraction::Base
    interface :record
    string :type

    validates :type, inclusion: { in: %w[reserved blocked domain disputed zone] }

    def execute
      send "update_#{type}", record
    end

    def update_domain(domain)
      domain.whois_record ? domain.whois_record.save : domain.create_whois_record
    end

    def update_reserved(record)
      record.generate_data
    end

    def update_blocked(record)
      update_reserved(record)
    end

    def update_disputed(record)
      update_reserved(record)
    end

    def update_zone(record)
      update_reserved(record)
    end
  end
end
