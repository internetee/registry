module Domains
  module UpdateConfirm
    class ProcessAction < Base
      def execute
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
