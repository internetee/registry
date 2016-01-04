class Pricelist < ActiveRecord::Base
  include Versions # version/pricelist_version.rb

  scope :valid, lambda {
    where(
      "valid_from <= ? AND (valid_to >= ? OR valid_to IS NULL)",
      Time.zone.now.end_of_day, Time.zone.now.beginning_of_day
    )
  }

  monetize :price_cents

  validates :price_cents, :price_currency, :price,
    :valid_from, :category, :operation_category, :duration, presence: true

  CATEGORIES = %w(ee pri.ee fie.ee med.ee com.ee)
  OPERATION_CATEGORIES = %w(create renew)
  DURATIONS = %w(1year 2years 3years)

  after_initialize :init_values
  def init_values
    return unless new_record?
    self.valid_from = Time.zone.now.beginning_of_year unless valid_from
  end

  def name
    "#{operation_category} #{category}"
  end

  class << self
    def pricelist_for(zone, operation, period)
      lists = valid.where(category: zone, operation_category: operation, duration: period)
      return lists.first if lists.count == 1
      lists.order(valid_from: :desc).first
    end
  end
end
