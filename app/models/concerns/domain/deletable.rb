module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  included do
    alias_attribute :delete_time, :delete_at
  end

  def discarded?
    statuses.include?(DomainStatus::DELETE_CANDIDATE)
  end
end
