module Domains
  module UpdateConfirm
    class ProcessAction < Base
      def execute
        ::PaperTrail.request.whodunnit = "interaction - #{self.class.name} - #{action} by"\
          " #{initiator}"

        case action
        when RegistrantVerification::CONFIRMED
          compose(ProcessUpdateConfirmed, inputs)
        when RegistrantVerification::REJECTED
          compose(ProcessUpdateRejected, inputs)
        end
      end
    end
  end
end
