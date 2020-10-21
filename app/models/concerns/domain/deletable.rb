module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  def deletion_time
    @deletion_time ||= Time.zone.at(rand(deletion_time_span))
  end

  private

  def delete_later
    DomainDeleteJob.set(wait_until: deletion_time).perform_later(id)
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
    delete_date + 24.hours
  end
end
