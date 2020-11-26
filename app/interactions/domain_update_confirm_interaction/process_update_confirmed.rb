module DomainUpdateConfirmInteraction
  class ProcessUpdateConfirmed < Base
    def execute
      ActiveRecord::Base.transaction do
        domain.is_admin = true
        old_registrant = domain.registrant
        notify_registrar(:poll_pending_update_confirmed_by_registrant)

        apply_pending_update!
        raise_errors!(domain)
        RegistrantChange.new(domain: domain, old_registrant: old_registrant).confirm
      end
    end

    def apply_pending_update!
      preclean_pendings
      update_domain
      clean_pendings!
      domain.save!

      WhoisRecord.find_by(domain_id: domain.id).save # need to reload model
    end

    def preclean_pendings
      domain.registrant_verification_token = nil
      domain.registrant_verification_asked_at = nil
    end

    def update_domain
      user = ApiUser.find(domain.pending_json['current_user_id'])
      frame = Nokogiri::XML(domain.pending_json['frame'])
      domain.upid = user.registrar.id if user.registrar
      domain.update(frame, user, false)
    end

    def clean_pendings!
      domain.up_date = Time.zone.now
      domain.registrant_verification_token = nil
      domain.registrant_verification_asked_at = nil
      domain.pending_json = {}
      clear_statuses
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
