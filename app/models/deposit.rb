class Deposit
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include DisableHtml5Validation

  attr_accessor :description, :registrar, :registrar_id
  attr_writer :amount

  validates :amount, :registrar, presence: true
  validate :validate_amount

  def validate_amount
    minimum_allowed_amount = [0.01, Setting.minimum_deposit].max
    return if amount >= minimum_allowed_amount
    errors.add(:amount, I18n.t(:is_too_small_minimum_deposit_is, amount: minimum_allowed_amount,
                                                                 currency: 'EUR'))
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def amount
    return BigDecimal('0.0') if @amount.blank?
    BigDecimal(@amount, 10)
  end

  def issue_prepayment_invoice
    return unless valid?
    registrar.issue_prepayment_invoice(amount, description)
  end
end
