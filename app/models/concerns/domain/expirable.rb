module Domain::Expirable
  extend ActiveSupport::Concern

  included do
    alias_attribute :expire_time, :valid_to
  end

  class_methods do
    def expired
      where(arel_table[attribute_alias(:expire_time)].lteq(Time.zone.now))
    end
  end

  def registered?
    !expired?
  end

  def expire_time
    valid_to
  end

  def expired?
    expire_time && expire_time <= Time.zone.now
  end

  def expirable?
    return false if expire_time > Time.zone.now

    return false if statuses.include?(DomainStatus::EXPIRED) && outzone_at.present? && delete_date.present?

    true
  end
end
