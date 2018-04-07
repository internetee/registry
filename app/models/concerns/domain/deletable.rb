module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  def discard
    statuses << DomainStatus::DELETE_CANDIDATE
    save
  end

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end
end
