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

  validates :name, :phone, :email, :ident, :address, :registrar, :ident_type, presence: true

  # Phone nr validation is very minimam in order to support legacy requirements
  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/
  validates :email, format: /@/
  validates :ident, format: /\d{4}-\d{2}-\d{2}/, if: proc { |c| c.ident_type == 'birthday' }
  validate :ident_must_be_valid
  validates :code, uniqueness: { message: :epp_id_taken }

  delegate :street,       to: :address
  delegate :city,         to: :address
  delegate :zip,          to: :address
  delegate :state,        to: :address
  delegate :country_code, to: :address
  delegate :country,      to: :address

  before_create :generate_code
  before_create :generate_auth_info
  after_create :ensure_disclosure

  scope :current_registrars, ->(id) { where(registrar_id: id) }

  IDENT_TYPE_ICO = 'ico'
  IDENT_TYPES = [
    IDENT_TYPE_ICO, # Company registry code (or similar)
    'bic',          # Business registry code
    'priv',         # National idendtification number
    'op',           # Estonian ID, depricated
    'passport',     # Passport number, depricated
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

  def ident_must_be_valid
    # TODO: Ident can also be passport number or company registry code.
    # so have to make changes to validations (and doc/schema) accordingly
    return true unless ident.present? && ident_type.present? && ident_type == 'op'
    code = Isikukood.new(ident)
    errors.add(:ident, 'bad format') unless code.valid?
  end

  def ensure_disclosure
    create_disclosure! unless disclosure
  end

  def juridical?
    ident_type == IDENT_TYPE_ICO
  end

  def citizen?
    ident_type != IDENT_TYPE_ICO
  end

  # generate random id for contact
  def generate_code
    self.code = SecureRandom.hex(4)
  end

  def generate_auth_info
    self.auth_info = SecureRandom.hex(16)
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
end
