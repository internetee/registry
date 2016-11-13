class DomainUpdateConfirmJob < Que::Job
  def run(domain_id, action, initiator = nil)
    ::PaperTrail.whodunnit = "job - #{self.class.name} - #{action} by #{initiator}"
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)
      domain.is_admin = true
      case action
      when RegistrantVerification::CONFIRMED
        domain.poll_message!(:poll_pending_update_confirmed_by_registrant)
        raise_errors!(domain)

        domain.apply_pending_update!
        raise_errors!(domain)

        domain.clean_pendings!
        raise_errors!(domain)
      when RegistrantVerification::REJECTED
        RegistrantChangeMailer.rejected(domain: domain, registrar: domain.registrar, registrant: domain.registrant)
          .deliver

        domain.poll_message!(:poll_pending_update_rejected_by_registrant)
        domain.clean_pendings_lowlevel
      end
      destroy # it's best to destroy the job in the same transaction
    end
  end

  def raise_errors!(domain)
    throw "domain #{domain.name} failed with errors #{domain.errors.full_messages}" if domain.errors.any?
  end
end
