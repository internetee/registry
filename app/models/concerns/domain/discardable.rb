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
    raise 'Domain is already discarded' if discarded?

    statuses << DomainStatus::DELETE_CANDIDATE
    transaction do
      save(validate: false)
      delete_later
    end
  end

  def keep
    statuses.delete(DomainStatus::DELETE_CANDIDATE)
    transaction do
      save(validate: false)
      do_not_delete_later
    end
  end

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end
end
