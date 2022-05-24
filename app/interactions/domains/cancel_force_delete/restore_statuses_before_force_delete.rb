module Domains
  module CancelForceDelete
    class RestoreStatusesBeforeForceDelete < Base
      def execute
        domain.statuses += domain.force_delete_domain_statuses_history || []
        domain.statuses += domain.admin_store_statuses_history || []
        domain.statuses.uniq!

        domain.force_delete_domain_statuses_history = nil
        domain.admin_store_statuses_history = nil
        domain.save(validate: false)
      end
    end
  end
end
