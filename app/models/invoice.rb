class Invoice < ActiveRecord::Base
  include Versions
  include Concerns::Invoice::Cancellable
  include Concerns::Invoice::Payable

  belongs_to :seller, class_name: 'Registrar'
  belongs_to :buyer, class_name: 'Registrar'
  has_one  :account_activity
  has_many :items, class_name: 'InvoiceItem', dependent: :destroy
  has_many :directo_records, as: :item, class_name: 'Directo'

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

  validates :issue_date, presence: true
  validates :due_date, :currency, :seller_name,
            :seller_iban, :buyer_name, :items, presence: true
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0, less_than: 100 },
            allow_nil: true

  before_create :set_invoice_number
  before_create :apply_default_vat_rate, unless: :vat_rate?
  before_create :calculate_total, unless: :total?
  before_create :apply_default_buyer_vat_no, unless: :buyer_vat_no?

  attribute :vat_rate, ::Type::VATRate.new
  attr_readonly :vat_rate

  def set_invoice_number
    last_no = Invoice.order(number: :desc).where('number IS NOT NULL').limit(1).pluck(:number).first

    if last_no && last_no >= Setting.invoice_number_min.to_i
      self.number = last_no + 1
    else
      self.number = Setting.invoice_number_min.to_i
    end

    return if number <= Setting.invoice_number_max.to_i

    errors.add(:base, I18n.t('failed_to_generate_invoice_invoice_number_limit_reached'))
    logger.error('INVOICE NUMBER LIMIT REACHED, COULD NOT GENERATE INVOICE')
    false
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
    return 0 unless vat_rate
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

  private

  def apply_default_vat_rate
    self.vat_rate = buyer.effective_vat_rate
  end

  def apply_default_buyer_vat_no
    self.buyer_vat_no = buyer.vat_no
  end

  def calculate_total
    self.total = subtotal + vat_amount
  end
end