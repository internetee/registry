class DomainSetDeleteCandidateJob < Que::Job

  def run(domain_id)
    domain = Domain.find(domain_id)
    domain.statuses << DomainStatus::DELETE_CANDIDATE
    domain.save(validate: false)
  end
end
