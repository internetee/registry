module Domains
  module CancelForceDelete
    class RestoreStatusesBeforeForceDelete < Base
      def execute
        domain.statuses = domain.force_delete_domain_statuses_history || []
        domain.statuses_before_force_delete = nil
        domain.force_delete_domain_statuses_history = nil
        domain.save(validate: false)
      end
    end
  end
end
