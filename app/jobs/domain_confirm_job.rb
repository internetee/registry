class DomainConfirmJob < Que::Job
  def run(domain_id, action)
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)
      case action
      when RegistrantVerification::CONFIRMED
        domain.apply_pending_update!
        domain.clean_pendings!
      when RegistrantVerification::REJECTED
        domain.clean_pendings!
      end
      destroy # it's best to destroy the job in the same transaction
    end
  end
end
