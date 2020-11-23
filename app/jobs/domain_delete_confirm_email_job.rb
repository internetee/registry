class DomainDeleteConfirmEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)
    DomainDeleteConfirmInteraction::SendRequest.run(domain: domain)
  end
end
