class Pricelist < ActiveRecord::Base
  include Versions # version/pricelist_version.rb

  scope :valid, -> { where("valid_from <= ? AND valid_to >= ? OR valid_to IS NULL", Time.zone.now, Time.zone.now) }

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
    def price_for(zone, operation, period)
      lists = valid.where(category: zone, operation_category: operation, duration: period)
      return lists.first.price if lists.count == 1
      lists.where('valid_to IS NOT NULL').order(valid_from: :desc).first.price
    end
  end
end
