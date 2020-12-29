module Domains
  module CancelForceDelete
    class CancelForceDelete < Base
      def execute
        compose(RemoveForceDeleteStatuses, inputs)
        compose(RestoreStatusesBeforeForceDelete, inputs)
        compose(ClearForceDeleteData, inputs)
        compose(NotifyRegistrar, inputs)
      end
    end
  end
end
