module Whois
  class Record < Whois::Server
    include ToStdout
    self.table_name = 'whois_records'

    def self.disclaimer
      Setting.registry_whois_disclaimer
    end

    # rubocop:disable Metrics/AbcSize
    def update_from_auction(auction)
      if auction.started?
        update!(json: { name: auction.domain,
                        status: ['AtAuction'],
                        disclaimer: self.class.disclaimer })
        to_stdout "Updated from auction WHOIS record #{inspect}"
      elsif auction.no_bids?
        to_stdout "Destroying WHOIS record #{inspect}"
        destroy!
      elsif auction.awaiting_payment? || auction.payment_received?
        update!(json: { name: auction.domain,
                        status: ['PendingRegistration'],
                        disclaimer: self.class.disclaimer,
                        registration_deadline: auction.whois_deadline })
        to_stdout "Updated from auction WHOIS record #{inspect}"
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
