module Admin
  class DisputeCreation
    def initialize(dispute:)
      @dispute = dispute
    end

    def create
      dispute.generate_password unless dispute.password?

      return unless dispute.valid?(:admin)

      dispute.transaction do
        dispute.save!
        prohibit_domain_registrant_change
        sync_reserved_domain
        update_whois
      end

      dispute
    end

    private

    attr_reader :dispute

    def prohibit_domain_registrant_change
      domain = Domain.find_by(name: dispute.domain_name)

      return unless domain

      domain.prohibit_registrant_change
      domain.save!
    end

    def sync_reserved_domain
      reserved_domain = ReservedDomain.find_by(name: dispute.domain_name)

      return unless reserved_domain

      reserved_domain.password = @dispute.password
      reserved_domain.save!
    end

    def update_whois
      DNS::DomainName.update_whois(domain_name: dispute.domain_name)
    end
  end
end
