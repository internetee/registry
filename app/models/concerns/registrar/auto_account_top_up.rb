module Concerns::Registrar::AutoAccountTopUp
  extend ActiveSupport::Concern

  included do
    validates :auto_account_top_up_low_balance_threshold, numericality: { greater_than_or_equal_to: 0 },
              allow_nil: true
    validates :auto_account_top_up_amount, numericality:
      { greater_than_or_equal_to: proc { |registrar| registrar.class.min_top_up_amount } },
              allow_nil: true
    validates_presence_of :auto_account_top_up_low_balance_threshold,
                          :auto_account_top_up_amount,
                          :auto_account_top_up_iban, if: :auto_account_top_up_activated?

    before_save :normalize_auto_account_top_up_iban
  end

  class_methods do
    def min_top_up_amount
      BigDecimal(Setting.minimum_deposit.to_s)
    end
  end

  private

  def normalize_auto_account_top_up_iban
    return if auto_account_top_up_iban.blank?
    self[:auto_account_top_up_iban] = auto_account_top_up_iban.gsub(/\s+/, '').upcase
  end
end
