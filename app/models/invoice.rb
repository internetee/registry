class Invoice < ApplicationRecord
  include Versions
  include Invoice::Cancellable
  include Invoice::Payable
  include Invoice::BookKeeping

  belongs_to :buyer, class_name: 'Registrar'
  has_one  :account_activity
  has_many :items, class_name: 'InvoiceItem', dependent: :destroy
  has_many :directo_records, as: :item, class_name: 'Directo'
  has_many :payment_orders

  accepts_nested_attributes_for :items
  # rubocop:disable Layout/LineLength
  # rubocop:disable Style/MultilineBlockLayout
  scope :all_columns,                    -> { select("invoices.*") }
  scope :sort_due_date_column,           -> { all_columns.select("CASE WHEN invoices.cancelled_at is not null THEN
                                                                (invoices.cancelled_at + interval '100 year') ELSE
                                                                 invoices.due_date END AS sort_due_date")
                                         }
  scope :sort_by_sort_due_date_asc,      -> { sort_due_date_column.order("sort_due_date ASC") }
  scope :sort_by_sort_due_date_desc,     -> { sort_due_date_column.order("sort_due_date DESC") }
  scope :sort_receipt_date_column,       -> { all_columns.includes(:account_activity).references(:account_activity).select(%(
                                            CASE WHEN account_activities.created_at is not null THEN account_activities.created_at
                                            WHEN invoices.cancelled_at is not null THEN invoices.cancelled_at + interval '100 year'
                                            ELSE NULL END AS sort_receipt_date ))
                                         }
  scope :sort_by_sort_receipt_date_asc,  -> { sort_receipt_date_column.order("sort_receipt_date ASC") }
  scope :sort_by_sort_receipt_date_desc, -> { sort_receipt_date_column.order("sort_receipt_date DESC") }

  scope :overdue, -> { unpaid.non_cancelled.where('due_date < ?', Time.zone.today) }
  # rubocop:enable Layout/LineLength
  # rubocop:enable Style/MultilineBlockLayout
  validates :due_date, :currency, :seller_name,
            :seller_iban, :buyer_name, :items, presence: true

  before_create :set_invoice_number
  before_create :calculate_total, unless: :total?
  before_create :apply_default_buyer_vat_no, unless: :buyer_vat_no?

  attribute :vat_rate, ::Type::VatRate.new

  def validate_invoice_number(result)
    response = JSON.parse(result.body)

    billing_restrictions_issue if response['code'] == '403'
    billing_out_of_range_issue if response['error'] == 'out of range'
  end

  def billing_restrictions_issue
    errors.add(:base, I18n.t('cannot get access'))
    logger.error('PROBLEM WITH TOKEN')
    throw(:abort)
  end

  def billing_out_of_range_issue
    errors.add(:base, I18n.t('failed_to_generate_invoice_invoice_number_limit_reached'))
    logger.error('INVOICE NUMBER LIMIT REACHED, COULD NOT GENERATE INVOICE')
    throw(:abort)
  end

  def invoice_number_from_billing
    result = EisBilling::GetInvoiceNumber.send_invoice
    validate_invoice_number(result)

    self.number = JSON.parse(result.body)['invoice_number'].to_i
  end

  def generate_invoice_number_legacy
    last_no = Invoice.all
                     .where(number: Setting.invoice_number_min.to_i...Setting.invoice_number_max.to_i)
                     .order(number: :desc)
                     .limit(1)
                     .pick(:number)

    if last_no && last_no >= Setting.invoice_number_min.to_i
      self.number = last_no + 1
    else
      self.number = Setting.invoice_number_min.to_i
    end

    return if number <= Setting.invoice_number_max.to_i

    billing_out_of_range_issue
  end

  def set_invoice_number
    if Feature.billing_system_integrated?
      invoice_number_from_billing
    else
      generate_invoice_number_legacy
    end
  end

  def to_s
    I18n.t('invoice_no', no: number)
  end

  def seller_address
    [seller_street, seller_city, seller_state, seller_zip].reject(&:blank?).compact.join(', ')
  end

  def buyer_address
    [buyer_street, buyer_city, buyer_state, buyer_zip].reject(&:blank?).compact.join(', ')
  end

  def seller_country
    Country.new(seller_country_code)
  end

  def buyer_country
    Country.new(buyer_country_code)
  end

  # order is used for directo/banklink description
  def order
    "Order nr. #{number}"
  end

  def subtotal
    items.map(&:item_sum_without_vat).reduce(:+)
  end

  def vat_amount
    subtotal * vat_rate / 100
  end

  def total
    calculate_total unless total?
    read_attribute(:total)
  end

  def each(&block)
    items.each(&block)
  end

  def as_pdf
    generator = PdfGenerator.new(self)
    generator.as_pdf
  end

  def to_e_invoice(payable: true)
    generator = Invoice::EInvoiceGenerator.new(self, payable)
    generator.generate
  end

  def do_not_send_e_invoice?
    e_invoice_sent? || cancelled?
  end

  def e_invoice_sent?
    e_invoice_sent_at.present?
  end

  def as_csv_row
    [
      number,
      buyer,
      cancelled? ? I18n.t(:cancelled) : due_date,
      receipt_date_status,
      issue_date,
      total,
      currency,
      seller_name,
    ]
  end

  def self.csv_header
    ['Number', 'Buyer', 'Due Date', 'Receipt Date', 'Issue Date', 'Total', 'Currency', 'Seller Name']
  end

  def self.create_from_transaction!(transaction)
    registrar_user = Registrar.find_by(reference_no: transaction.parsed_ref_number)
    return unless registrar_user

    vat = VatRateCalculator.new(registrar: registrar_user).calculate
    net = (transaction.sum / (1 + (vat / 100)))
    registrar_user.issue_prepayment_invoice(net, 'Direct top-up via bank transfer', payable: false)
  end

  private

  ransacker :number_str do
    Arel.sql(
      "regexp_replace(
        to_char(\"#{table_name}\".\"number\", '999999999999'), ' ', '', 'g')"
    )
  end

  def receipt_date_status
    if paid?
      receipt_date
    elsif cancelled?
      I18n.t(:cancelled)
    else
      I18n.t(:unpaid)
    end
  end

  def apply_default_buyer_vat_no
    self.buyer_vat_no = buyer.vat_no
  end

  def calculate_total
    self.total = (subtotal + vat_amount).round(3)
  end
end
