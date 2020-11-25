module DomainDeleteInteraction
  class Delete < Base
    def execute
      ::PaperTrail.request.whodunnit = "interaction - #{self.class.name}"
      WhoisRecord.where(domain_id: domain.id).destroy_all

      domain.destroy
      compose(DomainDeleteInteraction::NotifyRegistrar, inputs)
    end
  end
end
