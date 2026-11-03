module Domains
  class CancelPendingUpdate < ActiveInteraction::Base
    object :domain,
           class: Domain,
           description: 'Domain with a pending registrant change'
    string :initiator,
           default: nil

    validate :domain_has_pending_update

    def execute
      ::PaperTrail.request.whodunnit = "interaction - #{self.class.name} - cancelled by"\
        " #{initiator}"

      ActiveRecord::Base.transaction do
        notify_registrants
        clean_pendings!
      end

      UpdateWhoisRecordJob.perform_later(domain.name, 'domain')
    end

    private

    def domain_has_pending_update
      return if domain&.pending_update?

      errors.add(:domain, I18n.t(:object_status_prohibits_operation))
    end

    # Both parties already got a confirmation link that is about to become invalid,
    # so they are notified before the verification data is wiped.
    def notify_registrants
      RegistrantChangeMailer.cancelled(domain: domain,
                                       registrar: domain.registrar,
                                       registrant: domain.registrant,
                                       send_to: [domain.new_registrant_email,
                                                 domain.registrant.email]).deliver_later
    end

    def clean_pendings!
      domain.is_admin = true
      # Has to happen before save, otherwise before_update reinstates pendingUpdate
      domain.registrant_verification_token = nil
      domain.registrant_verification_asked_at = nil
      domain.pending_json = {}
      domain.statuses.delete(DomainStatus::PENDING_UPDATE)
      domain.status_notes[DomainStatus::PENDING_UPDATE] = ''
      domain.save!
    end
  end
end
