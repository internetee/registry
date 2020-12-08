module Domains
  module Delete
    class DoDelete < Base
      def execute
        ::PaperTrail.request.whodunnit = "interaction - #{self.class.name}"
        WhoisRecord.where(domain_id: domain.id).destroy_all

        domain.destroy
        compose(Domains::Delete::NotifyRegistrar, inputs)
      end
    end
  end
end
