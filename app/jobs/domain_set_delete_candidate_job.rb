class DomainSetDeleteCandidateJob < Que::Job

  def run(domain_id)
    domain = Domain.find(domain_id)
    domain.statuses << DomainStatus::DELETE_CANDIDATE
    domain.save(validate: false)
    DomainDeleteJob.enqueue(domain.id, run_at: rand(24*60).minutes.from_now)
  end
end
