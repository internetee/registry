module BalanceAutoReloadTypes
  class Threshold
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :amount, :threshold

    validates :amount, numericality: { greater_than_or_equal_to: :min_amount }
    validates :threshold, numericality: { greater_than_or_equal_to: 0 }

    def min_amount
      Setting.minimum_deposit
    end

    def as_json(options = nil)
      { name: name }.merge(super)
                    .except('errors', 'validation_context')
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end
