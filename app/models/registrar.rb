class Registrar < ActiveRecord::Base
  include Versions # version/registrar_version.rb

  has_many :domains, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :api_users, dependent: :restrict_with_error
  has_many :messages
  has_many :invoices, foreign_key: 'buyer_id'
  has_many :accounts
  has_many :nameservers, through: :domains
  has_many :whois_records
  has_many :priv_contacts, -> { privs }, class_name: 'Contact'
  has_many :white_ips, dependent: :destroy

  validates :name, :reg_no, :country_code, :email, :code, presence: true
  validates :name, :reg_no, :reference_no, :code, uniqueness: true
  validate :forbidden_codes
  def forbidden_codes
    return true unless ['CID'].include? code
    errors.add(:code, I18n.t(:forbidden_code))
    false
  end

  before_validation :generate_iso_11649_reference_no
  def generate_iso_11649_reference_no
    return if reference_no.present?

    loop do
      base = nil
      loop do
        base = SecureRandom.random_number.to_s.last(8)
        break if base.to_i != 0 && base.length == 8
      end

      control_base = (base + '2715' + '00').to_i
      reminder = control_base % 97
      check_digits = 98 - reminder

      check_digits = check_digits < 10 ? "0#{check_digits}" : check_digits.to_s

      self.reference_no = "RF#{check_digits}#{base}"
      break unless self.class.exists?(reference_no: reference_no)
    end
  end

  validates :email, :billing_email, format: /@/, allow_blank: true

  WHOIS_TRIGGERS = %w(name email phone street city state zip)

  after_save :update_whois_records
  def update_whois_records
    return true unless changed? && (changes.keys & WHOIS_TRIGGERS).present?
    whois_records.map(&:save) # slow currently
  end

  class << self
    def search_by_query(query)
      res = search(name_or_reg_no_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v[:name]} (#{v[:reg_no]})" } }
    end

    def eis
      find_by(reg_no: '90010019')
    end

    def ordered
      order(name: :asc)
    end
  end

  def issue_prepayment_invoice(amount, description = nil) # rubocop:disable Metrics/MethodLength
    # Currently only EIS can issue invoices
    eis = self.class.eis

    invoices.create(
      invoice_type: 'DEB',
      due_date: Time.zone.now.to_date + 1.day,
      payment_term: 'prepayment',
      description: description,
      currency: 'EUR',
      vat_prc: 0.2,
      seller_id: eis.id,
      seller_name: eis.name,
      seller_reg_no: eis.reg_no,
      seller_iban: Setting.eis_iban,
      seller_bank: Setting.eis_bank,
      seller_swift: Setting.eis_swift,
      seller_vat_no: eis.vat_no,
      seller_country_code: eis.country_code,
      seller_state: eis.state,
      seller_street: eis.street,
      seller_city: eis.city,
      seller_zip: eis.zip,
      seller_phone: eis.phone,
      seller_url: eis.url,
      seller_email: eis.email,
      seller_contact_name: Setting.eis_invoice_contact,
      buyer_id: id,
      buyer_name: name,
      buyer_reg_no: reg_no,
      buyer_country_code: country_code,
      buyer_state: state,
      buyer_street: street,
      buyer_city: city,
      buyer_zip: zip,
      buyer_phone: phone,
      buyer_url: url,
      buyer_email: email,
      reference_no: reference_no,
      invoice_items_attributes: [
        {
          description: 'prepayment',
          unit: 'piece',
          amount: 1,
          price: amount
        }
      ]
    )
  end

  def cash_account
    accounts.find_by(account_type: Account::CASH)
  end

  def domain_transfers
    at = DomainTransfer.arel_table
    DomainTransfer.where(
      at[:transfer_to_id].eq(id).or(
        at[:transfer_from_id].eq(id)
      )
    )
  end

  def address
    [street, city, state, zip].reject(&:blank?).compact.join(', ')
  end

  def to_s
    name
  end

  def country
    Country.new(country_code)
  end

  def code=(code)
    self[:code] = code.gsub(/[ :]/, '').upcase if new_record? && code.present?
  end
end
