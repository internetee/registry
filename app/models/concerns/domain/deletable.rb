module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  private

  def delete_later
    deletion_time = Time.zone.at(rand(deletion_time_span))
    DomainDeleteJob.enqueue(id, run_at: deletion_time)
    logger.info "Domain #{name} is scheduled to be deleted around #{deletion_time}"
  end

  def do_not_delete_later
    QueJob.find_by!("args->>0 = '#{id}'", job_class: DomainDeleteJob.name).destroy!
  end

  def deletion_time_span
    # 5 minutes to ensure we don't create a background job with past `run_at`
    ((Time.zone.now + 5.minutes).to_i)..(deletion_deadline.to_i)
  end

  def deletion_deadline
    delete_at + 24.hours
  end
end
