module Whois
  class DeleteRecord < ActiveInteraction::Base
    string :name
    string :type

    validates :type, inclusion: { in: %w[reserved blocked domain disputed zone] }

    def execute
      send "delete_#{type}", name
    end

    # 1. deleting own
    # 2. trying to regenerate reserved in order domain is still in the list
    def delete_domain(name)
      WhoisRecord.where(name: name).destroy_all

      BlockedDomain.find_by(name: name).try(:generate_data)
      ReservedDomain.find_by(name: name).try(:generate_data)
      Dispute.active.find_by(domain_name: name).try(:generate_data)
    end

    def delete_reserved(name)
      remove_status_from_whois(domain_name: name, domain_status: 'Reserved')
    end

    def delete_blocked(name)
      delete_reserved(name)
    end

    def delete_disputed(name)
      return if Dispute.active.find_by(domain_name: name).present?

      remove_status_from_whois(domain_name: name, domain_status: 'disputed')
    end

    def delete_zone(name)
      WhoisRecord.where(name: name).destroy_all
      Whois::Record.where(name: name).destroy_all
    end

    def remove_status_from_whois(domain_name:, domain_status:)
      Whois::Record.where(name: domain_name).each do |r|
        r.json['status'] = r.json['status'].delete_if { |status| status == domain_status }
        r.json['status'].blank? ? r.destroy : r.save
      end
    end
  end
end
