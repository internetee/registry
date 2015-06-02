class Contact < ActiveRecord::Base
  include Versions # version/contact_version.rb
  include EppErrors

  belongs_to :registrar
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts
  has_many :statuses, class_name: 'ContactStatus', dependent: :destroy
  has_many :legal_documents, as: :documentable

  accepts_nested_attributes_for :legal_documents

  validates :name, :phone, :email, :ident, :ident_type,
   :street, :city, :zip, :country_code, :registrar, presence: true

  # Phone nr validation is very minimam in order to support legacy requirements
  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/
  validates :email, format: /@/
  validates :ident,
    format: { with: /\d{4}-\d{2}-\d{2}/, message: :invalid_birthday_format },
    if: proc { |c| c.ident_type == 'birthday' }
  validates :ident_country_code, presence: true, if: proc { |c| %w(bic priv).include? c.ident_type }
  validates :code,
    uniqueness: { message: :epp_id_taken },
    format: { with: /\A[\w\-\:]*\Z/i },
    length: { maximum: 100 }
  validate :ident_valid_format?

  before_validation :set_ident_country_code
  before_validation :prefix_code
  before_create :generate_auth_info

  before_update :manage_emails
  def manage_emails
    return nil unless email_changed?
    ContactMailer.email_updated(self).deliver_now
  end

  after_save :manage_statuses
  def manage_statuses
    ContactStatus.manage(statuses, self)
    statuses.reload
  end

  scope :current_registrars, ->(id) { where(registrar_id: id) }

  BIC = 'bic'
  PRIV = 'priv'
  BIRTHDAY = 'birthday'
  PASSPORT = 'passport'

  IDENT_TYPES = [
    BIC,     # Company registry code (or similar)
    PRIV,    # National idendtification number
    BIRTHDAY # Birthday date
  ]

  attr_accessor :deliver_emails

  class << self
    def search_by_query(query)
      res = search(code_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v.name} (#{v.code})" } }
    end

    def find_orphans
      Contact.where('
        NOT EXISTS(
          select 1 from domains d where d.registrant_id = contacts.id
        ) AND NOT EXISTS(
          select 1 from domain_contacts dc where dc.contact_id = contacts.id
        )
      ')
    end

    def destroy_orphans
      logger.info "#{Time.zone.now.utc} - Destroying orphaned contacts\n"
      count = find_orphans.destroy_all.count
      logger.info "#{Time.zone.now.utc} - Successfully destroyed #{count} orphaned contacts\n"
    end

    def privs
      where("ident_type = '#{PRIV}'")
    end
  end

  def roid
    "EIS-#{id}"
  end

  def to_s
    name || '[no name]'
  end

  def ident_valid_format?
    case ident_type
    when 'priv'
      case ident_country_code
      when 'EE'
        code = Isikukood.new(ident)
        errors.add(:ident, :invalid_EE_identity_format) unless code.valid?
      end
    end
  end

  def bic?
    ident_type == BIC
  end

  def priv?
    ident_type != BIC
  end

  def generate_auth_info
    return if @generate_auth_info_disabled
    self.auth_info = SecureRandom.hex(11)
  end

  def disable_generate_auth_info! # needed for testing
    @generate_auth_info_disabled = true
  end

  def auth_info=(pw)
    self[:auth_info] = pw if new_record?
  end

  def code=(code)
    self[:code] = code if new_record? # cannot change code later
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def prefix_code
    return nil unless new_record?
    return nil if registrar.blank?
    code = self[:code]

    # custom code from client
    # add prefix when needed
    if code.present?
      prefix, *custom_code = code.split(':')
      code = custom_code.join(':') if prefix == registrar.code
    end

    code = SecureRandom.hex(4) if code.blank? || code == registrar.code

    self[:code] = "#{registrar.code}:#{code}".upcase
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # used only for contact trasphere
  def generate_new_code!
    return nil if registrar.blank?
    registrar.reload # for contact transfere
    self[:code] = "#{registrar.code}:#{SecureRandom.hex(4)}".upcase
  end

  def country
    Country.new(country_code)
  end

  # Find a way to use self.domains with contact
  def domains_owned
    Domain.where(registrant_id: id)
  end

  def relations_with_domain?
    return true if domain_contacts.present? || domains_owned.present?
    false
  end

  # TODO: refactor, it should not allow to destroy with normal destroy,
  # no need separate method
  # should use only in transaction
  def destroy_and_clean
    if relations_with_domain?
      errors.add(:domains, :exist)
      return false
    end
    destroy
  end

  def set_ident_country_code
    return true unless ident_country_code_changed? && ident_country_code.present?
    code = Country.new(ident_country_code)
    if code
      self.ident_country_code = code.alpha2
    else
      errors.add(:ident, :invalid_country_code)
    end
  end
end
