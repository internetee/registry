module Disputes
  class Close
    def initialize(dispute:)
      @dispute = dispute
    end

    def close
      closed = dispute.destroy!

      if closed
        update_whois
      end

      closed
    end

    private

    attr_reader :dispute

    def update_whois
      DNS::DomainName.update_whois(domain_name: dispute.domain_name)
    end
  end
end
