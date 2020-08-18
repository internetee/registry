module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'

    def self.disclaimer
      Setting.registry_whois_disclaimer
    end

    def update_from_auction(auction)
      if auction.started?
        update!(json: { name: auction.domain,
                        status: ['AtAuction'],
                        disclaimer: self.class.disclaimer })
      elsif auction.no_bids?
        destroy!
      elsif auction.awaiting_payment? || auction.payment_received?
        update!(json: { name: auction.domain,
                        status: ['PendingRegistration'],
                        disclaimer: self.class.disclaimer,
                        registration_deadline: auction.whois_deadline })
      end
    end
  end
end
