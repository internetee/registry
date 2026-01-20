class DNSValidationJob < ApplicationJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)
    DNSValidator.validate(domain: domain, name: domain.name, record_type: 'all')
  end
end
