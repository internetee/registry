module Whois
  class UpdateRecord < ActiveInteraction::Base
    hash :record do
      string :klass
      integer :id
      string :type
    end

    def execute
      data = record['klass'].constantize.find_by(id: record['id'])
      send "update_#{record['type']}", data
    end

    # Unique index on domain_id makes the loser of two concurrent jobs fail to create the
    # record, it updates the winner's one instead. Savepoint keeps an outer transaction usable.
    def update_domain(domain)
      WhoisRecord.transaction(requires_new: true) do
        domain.whois_record ? domain.whois_record.save : domain.create_whois_record
      end
    rescue ActiveRecord::RecordNotUnique
      domain.reload.whois_record.save
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
