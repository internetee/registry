module Domains
  module ForceDelete
    class SetForceDelete < Base
      def execute
        compose(CheckDiscarded, inputs.to_h)

        Domain.transaction do
          compose(PrepareDomain, inputs.to_h)
          compose(SetStatus, inputs.to_h)
          compose(PostSetProcess, inputs.to_h)

          # Save the domain once with all accumulated changes
          # This will create a single PaperTrail version
          domain.save(validate: false)

          compose(NotifyRegistrar, inputs.to_h)
          compose(NotifyByEmail, inputs.to_h)
          compose(NotifyMultiyearsExpirationDomain, inputs.to_h)
        end
      end
    end
  end
end
