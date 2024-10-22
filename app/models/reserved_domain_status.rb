class ReservedDomainStatus < ApplicationRecord
  has_secure_token :access_token
  before_create :set_token_created_at

  belongs_to :reserved_domain, optional: true

  enum status: { pending: 0, paid: 1, canceled: 2, failed: 3 }

  before_validation :normalize_name, on: %w[create, update]
  validates :name, domain_name: true

  INITIATOR = 'business_registry'.freeze
  OK = '200'.freeze
  CREATED = '201'.freeze

  def token_expired? = token_created_at.nil? || token_created_at < 30.days.ago

  def refresh_token
    regenerate_access_token
    update(token_created_at: Time.current)
  end

  def reserve_domain
    return false unless save

    result = reservation_domain_proceeds
    if result.status_code_success
      update(status: :pending, linkpay_url: result.linkpay)

      true
    else
      update(status: :failed)
      errors.add(:base, result.details)
      false
    end
  end

  private

  def normalize_name
    self.name = SimpleIDN.to_unicode(name).mb_chars.downcase.strip
  end

  def set_token_created_at
    self.token_created_at = Time.current
  end

  def reservation_domain_proceeds
    invoice_number = fetch_invoice_number
    invoice = create_invoice(invoice_number)
    result = fetch_linkpay(invoice)
    wrap_result(result)
  end

  def fetch_invoice_number
    invoice_number = EisBilling::GetInvoiceNumber.call
    JSON.parse(invoice_number.body)['invoice_number'].to_i
  end

  def create_invoice(invoice_number)
    Struct.new(:total, :number, :buyer_name, :buyer_email, :description, :initiator, :reference_no, :reserved_domain_name, :token)
      .new(reservation_domain_price, invoice_number, nil, nil, 'description', INITIATOR, nil, name, access_token)
  end

  def fetch_linkpay(invoice) = EisBilling::AddDeposits.new(invoice).call

  def wrap_result(result)
    parsed_result = JSON.parse(result.body)
    Struct.new(:status_code_success, :linkpay, :details)
      .new(result.code == OK || result.code == CREATED, parsed_result['everypay_link'], parsed_result)
  end

  def reservation_domain_price = 124.00
end
