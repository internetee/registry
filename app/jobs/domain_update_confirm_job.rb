class DomainUpdateConfirmJob < ApplicationJob
  queue_as :default

  def perform(domain_id, action, initiator = nil)
    ::PaperTrail.request.whodunnit = "job - #{self.class.name} - #{action} by #{initiator}"
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)
      domain.is_admin = true
      case action
      when RegistrantVerification::CONFIRMED
        old_registrant = domain.registrant
        domain.notify_registrar(:poll_pending_update_confirmed_by_registrant)
        raise_errors!(domain)

        domain.apply_pending_update!
        raise_errors!(domain)

        domain.clean_pendings!
        raise_errors!(domain)
        RegistrantChange.new(domain: domain, old_registrant: old_registrant).confirm
      when RegistrantVerification::REJECTED
        RegistrantChangeMailer.rejected(domain: domain,
                                        registrar: domain.registrar,
                                        registrant: domain.registrant).deliver_now

        domain.notify_registrar(:poll_pending_update_rejected_by_registrant)

        domain.preclean_pendings
        domain.clean_pendings!
      end
    end
  end

  def raise_errors!(domain)
    throw "domain #{domain.name} failed with errors #{domain.errors.full_messages}" if domain.errors.any?
  end
end
