module Domains
  module CancelForceDelete
    class CancelForceDelete < Base
      def execute
        compose(RemoveForceDeleteStatuses, inputs.to_h)
        compose(RestoreStatusesBeforeForceDelete, inputs.to_h)
        compose(ClearForceDeleteData, inputs.to_h)
        compose(NotifyRegistrar, inputs.to_h)
      end
    end
  end
end
