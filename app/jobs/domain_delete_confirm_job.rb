class DomainDeleteConfirmJob < ApplicationJob
  queue_as :default

  def perform(domain_id, action, initiator = nil)
    ::PaperTrail.request.whodunnit = "job - #{self.class.name} - #{action} by #{initiator}"

    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)

      case action
      when RegistrantVerification::CONFIRMED
        action_confirmed(domain)

      when RegistrantVerification::REJECTED
        action_rejected(domain)
      end
    end
  end

  def raise_errors!(domain)
    throw "domain #{domain.name} failed with errors #{domain.errors.full_messages}" if domain.errors.any?
  end

  private

  def action_confirmed(domain)
    domain.notify_registrar(:poll_pending_delete_confirmed_by_registrant)
    domain.apply_pending_delete!
    raise_errors!(domain)
  end

  def action_rejected(domain)
    domain.statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
    domain.notify_registrar(:poll_pending_delete_rejected_by_registrant)

    domain.cancel_pending_delete
    domain.save(validate: false)
    raise_errors!(domain)
    notify_on_domain(domain)
  end

  def notify_on_domain(domain)
    if domain.registrant_verification_token.blank?
      Rails.logger.warn 'EMAIL NOT DELIVERED: registrant_verification_token is missing for '\
                        "#{domain.name}"
    elsif domain.registrant_verification_asked_at.blank?
      Rails.logger.warn 'EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for '\
                        "#{domain.name}"
    else
      DomainDeleteMailer.rejected(domain).deliver_now
    end
  end
end
