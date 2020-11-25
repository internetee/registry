class DomainDeleteJob < Que::Job

  def run(domain_id)
    domain = Domain.find(domain_id)

    DomainDeleteInteraction::Delete.run(domain: domain)
  end
end
