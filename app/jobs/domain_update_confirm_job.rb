class DomainUpdateConfirmJob < ApplicationJob
  def perform(domain_id, action, initiator = nil, actor = nil, operation_id = nil)
    domain = Epp::Domain.find_by(id: domain_id)
    return unless domain
    attrs = {
      domain: domain,
      action: action,
      initiator: initiator,
      actor: actor,
      operation_id: operation_id,
    }
    Domains::UpdateConfirm::ProcessAction.run(attrs)
  end
end
