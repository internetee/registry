module Domain::Deletable
  extend ActiveSupport::Concern

  DELETE_STATUSES = [
    DomainStatus::PENDING_DELETE_CONFIRMATION,
    DomainStatus::PENDING_DELETE,
    DomainStatus::FORCE_DELETE,
  ].freeze

  private

  def delete_later
    deletion_time = Time.zone.at(rand(deletion_time_span))
    DomainDeleteJob.enqueue(id, run_at: deletion_time, priority: 1)
    logger.info "Domain #{name} is scheduled to be deleted around #{deletion_time}"
  end

  def do_not_delete_later
    # Que job can be manually deleted in admin area UI
    QueJob.find_by("args->>0 = '#{id}'", job_class: DomainDeleteJob.name)&.destroy
  end

  def deletion_time_span
    range_params = [Time.zone.now.to_i, deletion_deadline.to_i].sort
    Range.new(*range_params)
  end

  def deletion_deadline
    (delete_date || Time.zone.now) + 24.hours
  end
end
