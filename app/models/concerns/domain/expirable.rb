module Concerns::Domain::Expirable
  extend ActiveSupport::Concern

  included do
    alias_attribute :expire_time, :valid_to
  end

  class_methods do
    def expired
      where("#{attribute_alias(:expire_time)} <= ?", Time.zone.now)
    end
  end

  def registered?
    !expired?
  end

  def expired?
    expire_time <= Time.zone.now
  end

  def expirable?
    return false if expire_time > Time.zone.now

    if statuses.include?(DomainStatus::EXPIRED) && outzone_at.present? && delete_at.present?
      return false
    end

    true
  end
end
