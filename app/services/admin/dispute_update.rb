module Admin
  class DisputeUpdate
    attr_reader :dispute

    def initialize(dispute:)
      @dispute = dispute
    end

    def update
      dispute.generate_password unless dispute.password?

      return unless dispute.valid?(:admin)

      dispute.transaction do
        dispute.save!
        sync_reserved_domain
      end

      dispute
    end

    private

    def sync_reserved_domain
      reserved_domain = ReservedDomain.find_by(name: @dispute.domain_name)

      return unless reserved_domain

      reserved_domain.password = @dispute.password
      reserved_domain.save!
    end
  end
end
