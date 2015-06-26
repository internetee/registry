class Deposit
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include DisableHtml5Validation

  attr_accessor :amount, :description, :registrar, :registrar_id

  validates :amount, :registrar, presence: true

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
