module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end
end
