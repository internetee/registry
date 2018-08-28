module Concerns::Domain::Discardable
  extend ActiveSupport::Concern

  class_methods do
    def discard_domains
      domains = where('delete_at < ? AND ? != ALL(coalesce(statuses, array[]::varchar[])) AND' \
        ' ? != ALL(COALESCE(statuses, array[]::varchar[]))',
                      Time.zone.now,
                      DomainStatus::SERVER_DELETE_PROHIBITED,
                      DomainStatus::DELETE_CANDIDATE)

      domains.each do |domain|
        domain.discard
        yield domain if block_given?
      end
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
