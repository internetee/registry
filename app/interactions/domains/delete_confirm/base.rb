module Domains
  module DeleteConfirm
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to confirm release'
      string :action
      string :initiator,
             default: nil

      validates :domain, :action, presence: true
      validates :action, inclusion: { in: [RegistrantVerification::CONFIRMED,
                                           RegistrantVerification::REJECTED] }

      def raise_errors!(domain)
        return unless domain.errors.any?

        message = "domain #{domain.name} failed with errors #{domain.errors.full_messages}"
        throw message
      end

      def notify_registrar(message_key)
        domain.registrar.notifications.create!(
          text: "#{I18n.t(message_key)}: #{domain.name}",
          attached_obj_id: domain.id,
          attached_obj_type: domain.class.to_s
        )
      end

      def preclean_pendings
        domain.registrant_verification_token = nil
        domain.registrant_verification_asked_at = nil
      end

      def clean_pendings!
        domain.is_admin = true
        domain.registrant_verification_token = nil
        domain.registrant_verification_asked_at = nil
        domain.pending_json = {}
        clear_statuses
        domain.save
      end

      def clear_statuses
        domain.statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
        domain.statuses.delete(DomainStatus::PENDING_UPDATE)
        domain.statuses.delete(DomainStatus::PENDING_DELETE)
        domain.status_notes[DomainStatus::PENDING_UPDATE] = ''
        domain.status_notes[DomainStatus::PENDING_DELETE] = ''
      end
    end
  end
end
