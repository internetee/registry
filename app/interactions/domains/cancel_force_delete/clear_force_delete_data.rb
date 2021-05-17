module Domains
  module CancelForceDelete
    class ClearForceDeleteData < Base
      def execute
        domain.force_delete_data = nil
        domain.force_delete_date = nil
        domain.force_delete_start = nil
        domain.status_notes[DomainStatus::FORCE_DELETE] = ''
        domain.save(validate: false)
      end
    end
  end
end
