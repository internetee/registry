module Domains
  module ForceDelete
    class SetForceDelete < Base
      def execute
        compose(CheckDiscarded, inputs.to_h)
        compose(PrepareDomain, inputs.to_h)
        compose(SetStatus, inputs.to_h)
        compose(PostSetProcess, inputs.to_h)
        compose(NotifyRegistrar, inputs.to_h)
        compose(NotifyByEmail, inputs.to_h)
        compose(NotifyMultiyearsExpirationDomain, inputs.to_h)
        puts "SetForceDelete has been executed"
      end
    end
  end
end
