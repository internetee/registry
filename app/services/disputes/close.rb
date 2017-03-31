module Disputes
  class Close
    def initialize(dispute:)
      @dispute = dispute
    end

    def close
      dispute.transaction do
        dispute.destroy!
        update_whois
      end

      dispute.destroyed?
    end

    private

    attr_reader :dispute

    def update_whois
      DNS::DomainName.update_whois(domain_name: dispute.domain_name)
    end
  end
end
