module DNS
  # Namespace is needed, because a class with the same name is defined by `domain_name` gem,
  # a dependency of `actionmailer`,
  class DomainName
    def initialize(name)
      @name = name
    end

    def available?
      !unavailable?
    end

    def available_with_code?(code)
      pending_auction.domain_registrable?(code)
    end

    def unavailable?
      at_auction? || awaiting_payment? || registered? || blocked? || zone_with_same_origin?
    end

    def unavailability_reason
      if registered?
        :registered
      elsif blocked?
        :blocked
      elsif zone_with_same_origin?
        :zone_with_same_origin
      elsif at_auction?
        :at_auction
      elsif awaiting_payment?
        :awaiting_payment
      end
    end

    def sell_at_auction
      auction = Auction.new
      auction.domain = name
      auction.start
      update_whois_from_auction(auction)
    end

    def at_auction?
      pending_auction&.started?
    end

    def awaiting_payment?
      pending_auction&.awaiting_payment?
    end

    def pending_registration?
      pending_auction&.payment_received?
    end

    def registered?
      Domain.find_by_idn(name)
    end

    def not_registered?
      !registered?
    end

    def blocked?
      BlockedDomain.where(name: name).any?
    end

    def reserved?
      ReservedDomain.where(name: name).any?
    end

    def auctionable?
      !not_auctionable?
    end

    def to_s
      name
    end

    private

    attr_reader :name

    def not_auctionable?
      blocked? || reserved?
    end

    def zone_with_same_origin?
      DNS::Zone.where(origin: name).any?
    end

    def pending_auction
      Auction.pending(self)
    end

    def update_whois_from_auction(auction)
      whois_record = Whois::Record.find_by!(name: name)
      whois_record.update_from_auction(auction)
    end
  end
end
