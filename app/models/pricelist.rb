class Pricelist < ActiveRecord::Base
  include Versions # version/pricelist_version.rb

  monetize :price_cents

  validates :price_cents, :price_currency, :price,
    :valid_from, :category, :operation_category, :duration, presence: true

  CATEGORIES = %w(ee pri.ee fie.ee med.ee com.ee)
  OPERATION_CATEGORIES = %w(new renew)
  DURATIONS = %w(1year 2years 3years)

  after_initialize :init_values
  def init_values
    return unless new_record?
    self.valid_from = Time.zone.now.beginning_of_year
  end

  def name
    "#{operation_category} #{category}"
  end
end
