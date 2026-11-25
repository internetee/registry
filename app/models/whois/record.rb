module Whois
  class Record < Whois::Server
    self.table_name = 'whois_records'

    def self.without_auctions
      ids = Whois::Record.all.select { |record| Auction.where(domain: record.name).blank? }
                         .pluck(:id)
      Whois::Record.where(id: ids)
    end

    def self.disclaimer
      Setting.registry_whois_disclaimer
    end

    # Concurrent writers can both miss the row and INSERT. The unique index on name makes
    # the loser fail with RecordNotUnique, after which the winner's row is used instead.
    # Savepoint keeps an outer transaction usable after the failed INSERT.
    def self.find_or_create_by_name!(name, &block)
      transaction(requires_new: true) { find_or_create_by!(name: name, &block) }
    rescue ActiveRecord::RecordNotUnique
      find_by!(name: name)
    end

    # Yields new or existing record to the block and saves it, retrying once as an
    # UPDATE when a concurrent writer has inserted the same name in the meantime.
    def self.save_by_name(name)
      retried = false
      begin
        transaction(requires_new: true) do
          record = find_or_initialize_by(name: name)
          yield record
          record.save
        end
      rescue ActiveRecord::RecordNotUnique
        raise if retried

        retried = true
        retry
      end
    end

    # rubocop:disable Metrics/AbcSize
    def update_from_auction(auction)
      if auction.started?
        update!(json: { name: auction.domain,
                        status: ['AtAuction'],
                        disclaimer: self.class.disclaimer })
        ToStdout.msg "Updated from auction WHOIS record #{inspect}"
      elsif auction.no_bids?
        ToStdout.msg "Destroying WHOIS record #{inspect}"
        destroy!
      elsif auction.awaiting_payment? || auction.payment_received?
        update!(json: { name: auction.domain,
                        status: ['PendingRegistration'],
                        disclaimer: self.class.disclaimer,
                        registration_deadline: auction.whois_deadline })
        ToStdout.msg "Updated from auction WHOIS record #{inspect}"
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
