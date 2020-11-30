class DomainDeleteJob < Que::Job

  def run(domain_id)
    domain = Domain.find(domain_id)

    Domains::Delete::DoDelete.run(domain: domain)
  end
end
