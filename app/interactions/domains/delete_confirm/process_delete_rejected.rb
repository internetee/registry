module Domains
  module DeleteConfirm
    class ProcessDeleteRejected < Base
      def execute
        domain.statuses.delete(DomainStatus::PENDING_DELETE_CONFIRMATION)
        domain.notify_registrar(:poll_pending_delete_rejected_by_registrant)

        domain.cancel_pending_delete
        domain.save(validate: false)
        raise_errors!(domain)

        send_domain_delete_rejected_email
      end

      def send_domain_delete_rejected_email
        if domain.registrant_verification_token.blank?
          warn "EMAIL NOT DELIVERED: registrant_verification_token is missing for #{domain.name}"
        elsif domain.registrant_verification_asked_at.blank?
          warn "EMAIL NOT DELIVERED: registrant_verification_asked_at is missing for #{domain.name}"
        else
          send_email
        end
      end

      def warn(message)
        Rails.logger.warn(message)
      end

      def send_email
        DomainDeleteMailer.rejected(domain).deliver_now
      end
    end
  end
end
