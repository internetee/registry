module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'

    def self.disclaimer
      Setting.registry_whois_disclaimer
    end

    def self.refresh(domain_name)
      if domain_name.at_auction?
        create!(name: domain_name, json: { name: domain_name.to_s,
                                           status: 'AtAuction',
                                           disclaimer: disclaimer })
      elsif domain_name.awaiting_payment? || domain_name.pending_registration?
        find_by(name: domain_name.to_s).update!(json: { name: domain_name.to_s,
                                                        status: 'PendingRegistration',
                                                        disclaimer: disclaimer })
      else
        find_by(name: domain_name.to_s).destroy!
      end
    end
  end
end
