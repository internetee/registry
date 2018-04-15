module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  class_methods do
    def discard_domains
      domains = where('delete_at < ? AND ? != ALL(statuses) AND ? != ALL(statuses)',
                      Time.zone.now,
                      DomainStatus::SERVER_DELETE_PROHIBITED,
                      DomainStatus::DELETE_CANDIDATE)

      domains.map(&:discard)
    end
  end

  def discard
    statuses << DomainStatus::DELETE_CANDIDATE
    # We don't validate deliberately since nobody is interested in fixing discarded domain
    save(validate: false)
    delete_later
    logger.info "Domain #{name} (ID: #{id}) is scheduled to be deleted"
  end

  def keep
    statuses.delete(DomainStatus::DELETE_CANDIDATE)
    save
    do_not_delete_later
  end

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end

  private

  def delete_later
    run_at = rand(((24 * 60) - (DateTime.now.hour * 60 + DateTime.now.minute))).minutes.from_now
    DomainDeleteJob.enqueue(id, run_at: run_at)
  end

  def do_not_delete_later
    QueJob.find_by!("args->>0 = '#{id}'", job_class: DomainDeleteJob.name).delete
  end
end
