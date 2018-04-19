module Concerns::Domain::Discardable
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
    save(validate: false)
    do_not_delete_later
  end

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end
end
