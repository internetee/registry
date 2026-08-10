module Domains
  module UpdateConfirm
    class ProcessAction < Base
      def execute
        # The registrant decision arrives asynchronously, so the pending update may already
        # be gone by now - cancelled by the registrar or cleaned up by the expiry cron.
        return unless domain.pending_update?

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
