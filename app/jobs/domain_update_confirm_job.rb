class DomainUpdateConfirmJob < ApplicationJob
  def perform(domain_id, action, initiator = nil)
    domain = Epp::Domain.find(domain_id)
    Domains::UpdateConfirm::ProcessAction.run(domain: domain,
                                              action: action,
                                              initiator: initiator)
  end
end
