class DomainUpdateConfirmJob < ApplicationJob
  def perform(domain_id, action, initiator = nil)
    domain = Epp::Domain.find(domain_id)
    attrs = {
      domain: domain,
      action: action,
      initiator: initiator,
    }
    Domains::UpdateConfirm::ProcessAction.run(attrs)
  end
end
