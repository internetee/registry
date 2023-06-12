module Whois
  class UpdateRecord < ActiveInteraction::Base
    hash :record do
      string :klass
      integer :id
      string :type
    end

    def execute
      Whois::Record.transaction do
        data = record['klass'].constantize.find_by(id: record['id'])
        send "update_#{record['type']}", data
      end
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
