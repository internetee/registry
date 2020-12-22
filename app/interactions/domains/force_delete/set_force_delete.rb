module Domains
  module ForceDelete
    class SetForceDelete < Base
      def execute
        compose(CheckDiscarded, inputs)
        compose(PrepareDomain, inputs)
        compose(SetStatus, inputs)
        compose(PostSetProcess, inputs)
        compose(NotifyRegistrar, inputs)
        compose(NotifyByEmail, inputs)
      end
    end
  end
end
