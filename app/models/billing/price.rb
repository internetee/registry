module Billing
  class Price < ApplicationRecord
    attribute :duration, :interval
    include Billing::Price::Expirable
    include Versions

    belongs_to :zone, class_name: 'DNS::Zone', required: true
    has_many :account_activities

    validates :price, :valid_from, :operation_category, :duration, presence: true
    validates :operation_category, inclusion: { in: Proc.new { |price| price.class.operation_categories } }
    validates :duration, inclusion: { in: Proc.new { |price| price.class.durations.values } },
                         if: :should_validate_duration?

    alias_attribute :effect_time, :valid_from
    alias_attribute :expire_time, :valid_to
    monetize :price_cents, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
    after_initialize :init_values

    def should_validate_duration?
      new_record? || duration_changed?
    end

    def self.ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def self.operation_categories
      %w[create renew]
    end

    def self.durations
      {
        '3 months' => 3.months,
        '6 months' => 6.months,
        '9 months' => 9.months,
        '1 year' => 1.year,
        '2 years' => 2.years,
        '3 years' => 3.years,
        '4 years' => 4.years,
        '5 years' => 5.years,
        '6 years' => 6.years,
        '7 years' => 7.years,
        '8 years' => 8.years,
        '9 years' => 9.years,
        '10 years' => 10.years,
      }
    end

    def self.statuses
      %w[upcoming effective expired]
    end

    def self.upcoming
      where("#{attribute_alias(:effect_time)} > ?", Time.zone.now)
    end

    def self.effective
      condition = "#{attribute_alias(:effect_time)} <= :now " \
      " AND (#{attribute_alias(:expire_time)} >= :now" \
      " OR #{attribute_alias(:expire_time)} IS NULL)"
      where(condition, now: Time.zone.now)
    end

    def self.valid
      where('valid_from <= ? AND (valid_to >= ? OR valid_to IS NULL)', Time.zone.now.end_of_day,
            Time.zone.now.beginning_of_day)
    end

    def self.price_for(zone, operation_category, duration)
      lists = valid.where(zone: zone, operation_category: operation_category, duration: duration)
      return lists.first if lists.count == 1

      lists.order(valid_from: :desc).first
    rescue ActiveRecord::StatementInvalid
      nil
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
