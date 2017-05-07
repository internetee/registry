module Billing
  class Price < ActiveRecord::Base
    include Versions
    has_paper_trail class_name: '::PriceVersion'

    self.auto_html5_validation = false

    belongs_to :zone, class_name: 'DNS::Zone', required: true
    has_many :account_activities

    validates :price, :valid_from, :operation_category, :duration, presence: true
    validates :operation_category, inclusion: { in: Proc.new { |price| price.class.operation_categories } }
    validates :duration, inclusion: { in: Proc.new { |price| price.class.durations } }

    monetize :price_cents, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
    after_initialize :init_values

    def self.operation_categories
      %w[create renew]
    end

    def self.durations
      [
        '3 mons',
        '6 mons',
        '9 mons',
        '1 year',
        '2 years',
        '3 years',
        '4 years',
        '5 years',
        '6 years',
        '7 years',
        '8 years',
        '9 years',
        '10 years',
      ]
    end

    def self.valid
      where('valid_from <= ? AND (valid_to >= ? OR valid_to IS NULL)', Time.zone.now.end_of_day,
            Time.zone.now.beginning_of_day)
    end

    def self.price_for(zone, operation_category, duration)
      lists = valid.where(zone: zone, operation_category: operation_category, duration: duration)
      return lists.first if lists.count == 1
      lists.order(valid_from: :desc).first
    end

    def name
      "#{operation_category} #{zone_name}"
    end

    def zone_name
      zone.origin
    end

    def to_partial_path
      'price'
    end

    private

    def init_values
      return unless new_record?
      self.valid_from = Time.zone.now.beginning_of_year unless valid_from
    end
  end
end
