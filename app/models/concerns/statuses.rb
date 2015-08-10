module Statuses
  extend ActiveSupport::Concern

  def force_delete?
    statuses.include?(DomainStatus::FORCE_DELETE)
  end
end
