module Disputes
  class Update
    attr_reader :dispute

    def initialize(dispute:)
      @dispute = dispute
      dispute.generate_password unless dispute.password?
    end

    def update
      dispute.transaction do
        dispute.save!
        sync_reserved_domain
        update_whois
      end
    end

    private

    def sync_reserved_domain
      reserved_domain = ReservedDomain.find_by(name: @dispute.domain_name)

      return unless reserved_domain

      reserved_domain.password = @dispute.password
      reserved_domain.save!
    end

    def update_whois
      DNS::DomainName.update_whois(domain_name: dispute.domain_name)
    end
  end
end
