module Domains
  module DeleteConfirm
    class ProcessDeleteConfirmed < Base
      def execute
        domain.notify_registrar(:poll_pending_delete_confirmed_by_registrant)
        domain.apply_pending_delete!
        raise_errors!(domain)
      end
    end
  end
end
