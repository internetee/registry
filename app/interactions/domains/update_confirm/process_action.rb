module Domains
  module UpdateConfirm
    class ProcessAction < Base
      def execute
        unless domain.pending_update? &&
               (operation_id.nil? || operation_id == PendingOperationEvent.operation_id(domain.registrant_verification_token))
          Rails.logger.info("Skipping stale pending confirmation for domain #{domain.id}")
          return
        end

        ::PaperTrail.request.whodunnit = "interaction - #{self.class.name} - #{action} by"\
          " #{initiator}"

        case action
        when RegistrantVerification::CONFIRMED
          Domains::UpdateConfirm::ProcessUpdateConfirmed.run(inputs.to_h)
        when RegistrantVerification::REJECTED
          Domains::UpdateConfirm::ProcessUpdateRejected.run(inputs.to_h)
        end
      end
    end
  end
end
