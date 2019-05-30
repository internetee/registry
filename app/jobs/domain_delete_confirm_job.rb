class DomainDeleteConfirmJob < Que::Job
  def run(domain_id, action, initiator = nil)
    ::PaperTrail.whodunnit = "job - #{self.class.name} - #{action} by #{initiator}"
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)

      case action
      when RegistrantVerification::CONFIRMED
        domain.notify_registrar(:poll_pending_delete_confirmed_by_registrant)
        domain.apply_pending_delete!
        raise_errors!(domain)

      when RegistrantVerification::REJECTED
        domain.statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
        domain.notify_registrar(:poll_pending_delete_rejected_by_registrant)

        domain.cancel_pending_delete
        domain.save(validate: false)
        raise_errors!(domain)

        if domain.registrant_verification_token.blank?
          Rails.logger.warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{domain.name}"
        elsif domain.registrant_verification_asked_at.blank?
          Rails.logger.warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{domain.name}"
        else
          DomainDeleteMailer.rejected(domain).deliver_now
        end
      end

      destroy # it's best to destroy the job in the same transaction
    end
  end

  def raise_errors!(domain)
    throw "domain #{domain.name} failed with errors #{domain.errors.full_messages}" if domain.errors.any?
  end
end
