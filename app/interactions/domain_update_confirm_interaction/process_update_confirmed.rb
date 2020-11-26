module DomainUpdateConfirmInteraction
  class ProcessUpdateConfirmed < Base
    def execute
      ActiveRecord::Base.transaction do
        domain.is_admin = true
        old_registrant = domain.registrant
        domain.notify_registrar(:poll_pending_update_confirmed_by_registrant)

        domain.apply_pending_update!
        raise_errors!(domain)

        domain.clean_pendings!
        raise_errors!(domain)
        RegistrantChange.new(domain: domain, old_registrant: old_registrant).confirm
      end
    end


  end
end
