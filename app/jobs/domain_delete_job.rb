class DomainDeleteJob < ApplicationJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)

    Domains::Delete::DoDelete.run(domain: domain)
  end
end
