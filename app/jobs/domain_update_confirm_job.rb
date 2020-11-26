class DomainUpdateConfirmJob < ApplicationJob
  queue_as :default

  def perform(domain_id, action, initiator = nil)
    domain = Epp::Domain.find(domain_id)
    DomainUpdateConfirmInteraction::ProcessAction.run(domain: domain,
                                                      action: action,
                                                      initiator: initiator)
  end
end
