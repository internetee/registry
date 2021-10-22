module Whois
  class Update < ActiveInteraction::Base
    array :names
    string :type

    validates :type, inclusion: { in: %w[reserved blocked domain disputed zone] }

    def execute
      ::PaperTrail.request.whodunnit = "job - #{self.class.name} - #{type}"

      collection = determine_collection

      Array(names).each do |name|
        record = find_record(collection, name)
        if record
          Whois::UpdateRecord.run(record: { klass: record.class.to_s, id: record.id, type: type })
        else
          Whois::DeleteRecord.run(name: name, type: type)
        end
      end
    end

    private

    def determine_collection
      case type
      when 'reserved' then ReservedDomain
      when 'blocked'  then BlockedDomain
      when 'domain'   then Domain
      when 'disputed' then Dispute
      else                 DNS::Zone
      end
    end

    def find_record(collection, name)
      if collection == Dispute
        collection.find_by(domain_name: name)
      else
        collection == DNS::Zone ? collection.find_by(origin: name) : collection.find_by(name: name)
      end
    end
  end
end
