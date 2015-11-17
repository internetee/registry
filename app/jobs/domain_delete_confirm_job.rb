class DomainDeleteConfirmJob < Que::Job
  def run(domain_id, action)
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)
      case action
      when RegistrantVerification::CONFIRMED
        domain.poll_message!(:poll_pending_delete_confirmed_by_registrant)
        domain.apply_pending_delete!
        domain.clean_pendings!
      when RegistrantVerification::REJECTED
        DomainMailer.pending_delete_rejected_notification(domain_id).deliver
        domain.statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
        domain.poll_message!(:poll_pending_delete_rejected_by_registrant)
        domain.clean_pendings!
      end
      destroy # it's best to destroy the job in the same transaction
    end
  end
end
