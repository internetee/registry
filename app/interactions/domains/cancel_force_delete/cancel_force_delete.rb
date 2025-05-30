module Domains
  module CancelForceDelete
    class CancelForceDelete < Base
      def execute
        Domain.transaction do
          compose(RemoveForceDeleteStatuses, inputs.to_h)
          compose(RestoreStatusesBeforeForceDelete, inputs.to_h)
          compose(ClearForceDeleteData, inputs.to_h)

          # Save the domain once with all accumulated changes
          # This will create a single PaperTrail version
          domain.save(validate: false)

          compose(NotifyRegistrar, inputs.to_h)
        end
      end
    end
  end
end
