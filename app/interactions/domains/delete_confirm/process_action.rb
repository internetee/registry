module Domains
  module DeleteConfirm
    class ProcessAction < Base
      def execute
        ::PaperTrail.request.whodunnit = "interaction - #{self.class.name} - #{action} by"\
          " #{initiator}"

        case action
        when RegistrantVerification::CONFIRMED
          compose(ProcessDeleteConfirmed, inputs)
        when RegistrantVerification::REJECTED
          compose(ProcessDeleteRejected, inputs)
        end
      end
    end
  end
end
