module Concerns::Domain::Activatable
  extend ActiveSupport::Concern

  def active?
    !inactive?
  end

  def inactive?
    statuses.include?(DomainStatus::INACTIVE)
  end

  def activate
    statuses.delete(DomainStatus::INACTIVE)
  end

  def deactivate
    return if inactive?
    statuses << DomainStatus::INACTIVE
  end
end
