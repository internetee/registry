module Domains
  module CancelForceDelete
    class RestoreStatusesBeforeForceDelete < Base
      def execute
        domain.statuses = domain.statuses_before_force_delete
        domain.statuses_before_force_delete = nil
        domain.save(validate: false)
      end
    end
  end
end
