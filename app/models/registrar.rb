class Registrar < ActiveRecord::Base
  include Versions # version/registrar_version.rb

  has_many :domains, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :api_users, dependent: :restrict_with_error
  has_many :messages
  has_many :invoices, foreign_key: 'buyer_id'
  has_many :accounts
  has_many :nameservers, through: :domains
  has_many :priv_contacts, -> { privs }, class_name: 'Contact'
  has_many :white_ips, dependent: :destroy

  delegate :balance, to: :cash_account, allow_nil: true

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

  validates :email, :billing_email,
    email_format: { message: :invalid },
    allow_blank: true, if: proc { |c| c.email_changed? }

  class << self
    def search_by_query(query)
      res = search(name_or_reg_no_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v[:name]} (#{v[:reg_no]})" } }
    end

    def alphabetically
      order(name: :asc)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def issue_prepayment_invoice(amount, description = nil)
    invoices.create(
      invoice_type: 'DEB',
      due_date: (Time.zone.now.to_date + Setting.days_to_keep_invoices_active.days).end_of_day,
      payment_term: 'prepayment',
      description: description,
      currency: 'EUR',
      vat_prc: Setting.registry_vat_prc,
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
      buyer_id: id,
      buyer_name: name,
      buyer_reg_no: reg_no,
      buyer_country_code: country_code,
      buyer_state: state,
      buyer_street: street,
      buyer_city: city,
      buyer_zip: zip,
      buyer_phone: phone,
      buyer_url: website,
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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def cash_account
    accounts.find_by(account_type: Account::CASH)
  end

  def debit!(args)
    args[:sum] *= -1
    args[:currency] = 'EUR'
    cash_account.account_activities.create!(args)
  end

  def credit!(args)
    args[:currency] = 'EUR'
    cash_account.account_activities.create!(args)
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

  def api_ip_white?(ip)
    return true unless Setting.api_ip_whitelist_enabled
    white_ips.api.pluck(:ipv4, :ipv6).flatten.include?(ip)
  end

  def registrar_ip_white?(ip)
    return true unless Setting.registrar_ip_whitelist_enabled
    white_ips.registrar.pluck(:ipv4, :ipv6).flatten.include?(ip)
  end
end
