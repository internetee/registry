class Invoice < ApplicationRecord
  include Versions
  include Concerns::Invoice::Cancellable
  include Concerns::Invoice::Payable
  include Concerns::Invoice::BookKeeping

  belongs_to :buyer, class_name: 'Registrar'
  has_one  :account_activity
  has_many :items, class_name: 'InvoiceItem', dependent: :destroy
  has_many :directo_records, as: :item, class_name: 'Directo'
  has_many :payment_orders

  accepts_nested_attributes_for :items

  scope :all_columns,                    ->{select("invoices.*")}
  scope :sort_due_date_column,           ->{all_columns.select("CASE WHEN invoices.cancelled_at is not null THEN
                                                                (invoices.cancelled_at + interval '100 year') ELSE
                                                                 invoices.due_date END AS sort_due_date")}
  scope :sort_by_sort_due_date_asc,      ->{sort_due_date_column.order("sort_due_date ASC")}
  scope :sort_by_sort_due_date_desc,     ->{sort_due_date_column.order("sort_due_date DESC")}
  scope :sort_receipt_date_column,       ->{all_columns.includes(:account_activity).references(:account_activity).select(%Q{
                                            CASE WHEN account_activities.created_at is not null THEN account_activities.created_at
                                            WHEN invoices.cancelled_at is not null THEN invoices.cancelled_at + interval '100 year'
                                            ELSE NULL END AS sort_receipt_date })}
  scope :sort_by_sort_receipt_date_asc,  ->{sort_receipt_date_column.order("sort_receipt_date ASC")}
  scope :sort_by_sort_receipt_date_desc, ->{sort_receipt_date_column.order("sort_receipt_date DESC")}

  scope :overdue, -> { unpaid.non_cancelled.where('due_date < ?', Time.zone.today) }

  validates :due_date, :currency, :seller_name,
            :seller_iban, :buyer_name, :items, presence: true

  before_create :set_invoice_number
  before_create :calculate_total, unless: :total?
  before_create :apply_default_buyer_vat_no, unless: :buyer_vat_no?

  attribute :vat_rate, ::Type::VATRate.new

  def set_invoice_number
    last_no = Invoice.order(number: :desc).limit(1).pluck(:number).first

    if last_no && last_no >= Setting.invoice_number_min.to_i
      self.number = last_no + 1
    else
      self.number = Setting.invoice_number_min.to_i
    end

    return if number <= Setting.invoice_number_max.to_i

    errors.add(:base, I18n.t('failed_to_generate_invoice_invoice_number_limit_reached'))
    logger.error('INVOICE NUMBER LIMIT REACHED, COULD NOT GENERATE INVOICE')
    throw(:abort)
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

  def each
    items.each { |item| yield item }
  end

  def as_pdf
    generator = PdfGenerator.new(self)
    generator.as_pdf
  end

  def to_e_invoice
    generator = Invoice::EInvoiceGenerator.new(self)
    generator.generate
  end

  def do_not_send_e_invoice?
    e_invoice_sent? || cancelled? || paid?
  end

  def e_invoice_sent?
    e_invoice_sent_at.present?
  end

  def self.create_from_transaction!(transaction)
    registrar_user = Registrar.find_by(reference_no: transaction.parsed_ref_number)
    return unless registrar_user

    registrar_user.issue_prepayment_invoice(amount: transaction.sum,
                                            description: 'Direct top-up via bank transfer',
                                            paid: true)
  end

  private

  def apply_default_buyer_vat_no
    self.buyer_vat_no = buyer.vat_no
  end

  def calculate_total
    self.total = subtotal + vat_amount
  end
end
