module Domains
  class ResendPendingNotification < ActiveInteraction::Base
    object :domain,
           class: Domain,
           description: 'Domain with a pending registrant change or delete confirmation'

    validate :domain_has_pending_confirmation

    def execute
      if domain.pending_update?
        RegistrantChangeConfirmEmailJob.perform_later(domain.id, domain.pending_json['new_registrant_id'])
      else
        Domains::DeleteConfirmEmail::SendRequest.run(domain: domain)
      end
    end

    private

    def domain_has_pending_confirmation
      return if domain.registrant_verification_asked? &&
                (domain.pending_update? || domain.pending_delete_confirmation?)

      errors.add(:domain, I18n.t(:object_status_prohibits_operation))
    end
  end
end
