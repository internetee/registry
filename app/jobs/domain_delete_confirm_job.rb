class DomainDeleteConfirmJob < ApplicationJob
  queue_as :default

  def perform(domain_id, action, initiator = nil)
    domain = Epp::Domain.find(domain_id)

    Domains::DeleteConfirm::ProcessAction.run(domain: domain,
                                              action: action,
                                              initiator: initiator)
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
