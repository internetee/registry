class DomainUpdateConfirmJob < Que::Job
  def run(domain_id, action, initiator)
    ::PaperTrail.whodunnit = "job - #{self.class.name} - #{action} by #{initiator}"
    # it's recommended to keep transaction against job table as short as possible.
    ActiveRecord::Base.transaction do
      domain = Epp::Domain.find(domain_id)
      domain.is_admin = true
      case action
      when RegistrantVerification::CONFIRMED
        domain.poll_message!(:poll_pending_update_confirmed_by_registrant)
        domain.apply_pending_update!
        domain.clean_pendings!
      when RegistrantVerification::REJECTED
        domain.send_mail :pending_update_rejected_notification_for_new_registrant
        domain.poll_message!(:poll_pending_update_rejected_by_registrant)
        domain.clean_pendings_lowlevel
      end
      destroy # it's best to destroy the job in the same transaction
    end
  end
end
