class DomainDeleteJob < Que::Job
  def run(domain_id)
    ::PaperTrail.whodunnit = "job - #{self.class.name}"

    domain = Domain.find(domain_id)
    Domains::Delete.new(domain: domain).delete
  end
end
