module Domains
  module DeleteConfirm
    class ProcessAction < Base
      def execute
        unless domain.pending_delete_confirmation? && !domain.statuses.include?(DomainStatus::PENDING_DELETE) &&
               (operation_id.nil? || operation_id == PendingOperationEvent.operation_id(domain.registrant_verification_token))
          Rails.logger.info("Skipping stale pending confirmation for domain #{domain.id}")
          return
        end

        ::PaperTrail.request.whodunnit = "interaction - #{self.class.name} - #{action} by"\
          " #{initiator}"

        case action
        when RegistrantVerification::CONFIRMED
          compose(ProcessDeleteConfirmed, inputs.to_h)
        when RegistrantVerification::REJECTED
          compose(ProcessDeleteRejected, inputs.to_h)
        end
      end
    end
  end
end
