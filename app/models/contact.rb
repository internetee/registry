class Contact < ActiveRecord::Base
  include Versions # version/contact_version.rb

  has_one :address, dependent: :destroy
  has_one :disclosure, class_name: 'ContactDisclosure', dependent: :destroy

  has_many :domain_contacts
  has_many :domains, through: :domain_contacts
  has_many :statuses, class_name: 'ContactStatus'
  has_many :legal_documents, as: :documentable

  belongs_to :registrar

  accepts_nested_attributes_for :address, :disclosure, :legal_documents

  attr_accessor :code_overwrite_allowed

  validates :name, :phone, :email, :ident, :address, :registrar, :ident_type, presence: true

  # # Phone nr validation is very minimam in order to support legacy requirements
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

  delegate :street,       to: :address
  delegate :city,         to: :address
  delegate :zip,          to: :address
  delegate :state,        to: :address
  delegate :country_code, to: :address
  delegate :country,      to: :address

  before_validation :set_ident_country_code
  before_create :generate_code
  before_create :generate_auth_info
  after_create :ensure_disclosure
  after_save :manage_statuses
  def manage_statuses
    ContactStatus.manage(statuses, self)
    statuses.reload
  end

  scope :current_registrars, ->(id) { where(registrar_id: id) }

  IDENT_TYPE_BIC = 'bic'
  IDENT_TYPES = [
    IDENT_TYPE_BIC, # Company registry code (or similar)
    'priv',         # National idendtification number
    'birthday'      # Birthday date
  ]

  CONTACT_TYPE_TECH = 'tech'
  CONTACT_TYPE_ADMIN = 'admin'
  CONTACT_TYPES = [CONTACT_TYPE_TECH, CONTACT_TYPE_ADMIN]

  class << self
    def search_by_query(query)
      res = search(code_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v.name} (#{v.code})" } }
    end

    def check_availability(codes)
      codes = [codes] if codes.is_a?(String)

      res = []
      codes.each do |x|
        if Contact.find_by(code: x)
          res << { code: x, avail: 0, reason: 'in use' }
        else
          res << { code: x, avail: 1 }
        end
      end

      res
    end
  end

  def to_s
    name
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

  def ensure_disclosure
    create_disclosure! unless disclosure
  end

  def bic?
    ident_type == IDENT_TYPE_BIC
  end

  def priv?
    ident_type != IDENT_TYPE_BIC
  end

  def generate_code
    self.code = SecureRandom.hex(4) if code.blank? || code_overwrite_allowed
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
    self[:code] = code if new_record? || code_overwrite_allowed
  end

  # Find a way to use self.domains with contact
  def domains_owned
    Domain.where(owner_contact_id: id)
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
      errors.add(:ident_country_code, 'is not following ISO_3166-1 alpha 2 format')
    end
  end
end
