class Registrar < ApplicationRecord
  include Versions # version/registrar_version.rb
  include Concerns::Registrar::BookKeeping
  include Concerns::EmailVerifable
  include Concerns::Registrar::LegalDoc

  has_many :domains, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :api_users, dependent: :restrict_with_error
  has_many :notifications
  has_many :invoices, foreign_key: 'buyer_id'
  has_many :accounts, dependent: :destroy
  has_many :nameservers, through: :domains
  has_many :whois_records
  has_many :white_ips, dependent: :destroy

  delegate :balance, to: :cash_account, allow_nil: true

  validates :name, :reg_no, :email, :code, presence: true
  validates :name, :code, uniqueness: true
  validates :address_street, :address_city, :address_country_code, presence: true
  validates :accounting_customer_code, presence: true
  validates :language, presence: true
  validates :reference_no, format: Billing::ReferenceNo::REGEXP
  validate :forbid_special_code

  validates :vat_rate, presence: true, if: -> { vat_liable_in_foreign_country? && vat_no.blank? }
  validates :vat_rate, absence: true, if: :vat_liable_locally?
  validates :vat_rate, absence: true, if: -> { vat_liable_in_foreign_country? && vat_no? }
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0, less_than: 100 },
            allow_nil: true

  attribute :vat_rate, ::Type::VATRate.new
  after_initialize :set_defaults

  validate :correct_email_format, if: proc { |c| c.will_save_change_to_email? }
  validate :correct_billing_email_format

  alias_attribute :contact_email, :email

  WHOIS_TRIGGERS = %w(name email phone street city state zip)

  after_commit :update_whois_records
  def update_whois_records
    return true unless changed? && (changes.keys & WHOIS_TRIGGERS).present?
    RegenerateRegistrarWhoisesJob.enqueue id
  end

  self.ignored_columns = %w[legacy_id]

  class << self
    def ordered
      order(name: :asc)
    end
  end

  def issue_prepayment_invoice(amount, description = nil, payable: true)
    vat_rate = ::Invoice::VatRateCalculator.new(registrar: self).calculate

    invoice = invoices.create!(
      issue_date: Time.zone.today,
      due_date: (Time.zone.now + Setting.days_to_keep_invoices_active.days).to_date,
      description: description,
      currency: 'EUR',
      seller_name: Setting.registry_juridical_name,
      seller_reg_no: Setting.registry_reg_no,
      seller_iban: Setting.registry_iban,
      seller_bank: Setting.registry_bank,
      seller_swift: Setting.registry_swift,
      seller_vat_no: Setting.registry_vat_no,
      seller_country_code: Setting.registry_country_code,
      seller_state: Setting.registry_state,
      seller_street: Setting.registry_street,
      seller_city: Setting.registry_city,
      seller_zip: Setting.registry_zip,
      seller_phone: Setting.registry_phone,
      seller_url: Setting.registry_url,
      seller_email: Setting.registry_email,
      seller_contact_name: Setting.registry_invoice_contact,
      buyer: self,
      buyer_name: name,
      buyer_reg_no: reg_no,
      buyer_country_code: address_country_code,
      buyer_state: address_state,
      buyer_street: address_street,
      buyer_city: address_city,
      buyer_zip: address_zip,
      buyer_phone: phone,
      buyer_url: website,
      buyer_email: email,
      reference_no: reference_no,
      vat_rate: vat_rate,
      items_attributes: [
        {
          description: 'prepayment',
          unit: 'piece',
          quantity: 1,
          price: amount
        }
      ]
    )

    unless payable
      InvoiceMailer.invoice_email(invoice: invoice, recipient: billing_email).deliver_now
    end

    SendEInvoiceJob.enqueue(invoice.id, payable)

    invoice
  end

  def cash_account
    accounts.find_by(account_type: Account::CASH)
  end

  def debit!(args)
    args[:sum] *= -1
    args[:currency] = 'EUR'
    cash_account.account_activities.create!(args)
  end

  def address
    [address_street, address_city, address_state, address_zip].reject(&:blank?).compact.join(', ')
  end

  def to_s
    name
  end

  def country
    Country.new(address_country_code)
  end

  def code=(code)
    self[:code] = code.gsub(/[ :]/, '').upcase if new_record? && code.present?
  end

  def api_ip_white?(ip)
    return true unless Setting.api_ip_whitelist_enabled

    white_ips.api.include_ip?(ip)
  end

  # Audit log is needed, therefore no raw SQL
  def replace_nameservers(hostname, new_attributes, domains: [])
    transaction do
      domain_list = []

      nameservers.where(hostname: hostname).find_each do |original_nameserver|
        next unless domains.include?(original_nameserver.domain.name_puny) || domains.empty?

        new_nameserver = Nameserver.new
        new_nameserver.domain = original_nameserver.domain
        new_nameserver.attributes = new_attributes
        new_nameserver.save!

        domain_list << original_nameserver.domain.name

        original_nameserver.destroy!
      end

      domain_list.uniq.sort
    end
  end

  def vat_country=(country)
    self.address_country_code = country.alpha2
  end

  def vat_country
    country
  end

  def vat_liable_locally?(registry = Registry.current)
    vat_country == registry.vat_country
  end

  def notify(action)
    text = I18n.t("notifications.texts.#{action.notification_key}", contact: action.contact.code)
    notifications.create!(text: text)
  end

  def e_invoice_iban
    iban
  end

  def billing_email
    return contact_email if self[:billing_email].blank?
    self[:billing_email]
  end

  private

  def set_defaults
    self.language = Setting.default_language unless language
  end

  def forbid_special_code
    errors.add(:code, :forbidden) if code == 'CID'
  end

  def vat_liable_in_foreign_country?
    !vat_liable_locally?
  end
end
