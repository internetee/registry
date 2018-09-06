module BalanceAutoReloadTypes
  class Threshold
    include ActiveModel::Model

    attr_accessor :amount
    attr_accessor :threshold

    validates :amount, numericality: { greater_than_or_equal_to: :min_amount }
    validates :threshold, numericality: { greater_than_or_equal_to: 0 }

    def min_amount
      Setting.minimum_deposit
    end

    def as_json(options)
      { name: name }.merge(super)
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end