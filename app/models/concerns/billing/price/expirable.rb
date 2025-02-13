module Billing::Price::Expirable
  extend ActiveSupport::Concern

  class_methods do
    def expired
      where(arel_table[attribute_alias(:expire_time)].lt(Time.zone.now))
    end
  end

  def expire
    self[:valid_to] = Time.zone.now - 1
  end

  def expired?
    expire_time.past?
  end
end
