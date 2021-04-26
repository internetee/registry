module Domains
  module DeleteConfirm
    class ProcessAction < Base
      def execute
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
