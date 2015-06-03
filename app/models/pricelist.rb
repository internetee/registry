class Pricelist < ActiveRecord::Base
  include Versions # version/pricelist_version.rb

  monetize :price_cents

  validates :price_cents, :price_currency, :valid_from, :category, presence: true

  CATEGORIES = %w(ee com.ee fie.ee pri.ee med.ee)
  DURATIONS = %w(1year 2years 3years)

  after_initialize :init_values
  def init_values
    return unless new_record?
    self.valid_from = Time.zone.now.beginning_of_year
  end
end
