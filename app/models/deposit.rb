class Deposit
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include DisableHtml5Validation

  attr_accessor :amount, :description, :registrar, :registrar_id

  validates :amount, :registrar, presence: true
  validate :validate_amount
  def validate_amount
    return if BigDecimal.new(amount) >= Setting.minimum_deposit
    errors.add(:amount, I18n.t(:is_too_small_minimum_deposit_is, amount: Setting.minimum_deposit, currency: 'EUR'))
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def issue_prepayment_invoice
    valid? && registrar.issue_prepayment_invoice(amount, description)
  end
end
