class Contact < ActiveRecord::Base
  # TODO: Foreign contact will get email with activation link/username/temp password
  # TODO: Phone number validation, in first phase very minimam in order to support current registries
  # TODO: Validate presence of name

  include EppErrors

  # has_one :local_address, dependent: :destroy
  # has_one :international_address, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :disclosure, class_name: 'ContactDisclosure'

  has_many :domain_contacts
  has_many :domains, through: :domain_contacts

  # TODO remove the x_by
  belongs_to :created_by, class_name: 'EppUser', foreign_key: :created_by_id
  belongs_to :updated_by, class_name: 'EppUser', foreign_key: :updated_by_id
  belongs_to :registrar

  accepts_nested_attributes_for :address, :disclosure

  validates :code, :phone, :email, :ident, :address, :registrar, presence: true

  validate :ident_must_be_valid
  # validate :presence_of_one_address

  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/ # /\+\d{3}\.\d+/
  validates :email, format: /@/

  validates :code, uniqueness: { message: :epp_id_taken }

  delegate :country, to: :address # , prefix: true
  delegate :city, to: :address # , prefix: true
  delegate :street, to: :address # , prefix: true
  delegate :zip, to: :address # , prefix: true

  # scopes
  scope :current_registrars, ->(id) { where(registrar_id: id) }
  # archiving
  has_paper_trail class_name: 'ContactVersion'

  IDENT_TYPE_ICO = 'ico'
  IDENT_TYPES = [
    IDENT_TYPE_ICO, # Company registry code (or similar)
    'op',           # Estonian ID
    'passport',     # Passport number
    'birthday'      # Birthday date
  ]

  CONTACT_TYPE_TECH = 'tech'
  CONTACT_TYPE_ADMIN = 'admin'
  CONTACT_TYPES = [CONTACT_TYPE_TECH, CONTACT_TYPE_ADMIN]

  def ident_must_be_valid
    # TODO: Ident can also be passport number or company registry code.
    # so have to make changes to validations (and doc/schema) accordingly
    return true unless ident.present? && ident_type.present? && ident_type == 'op'
    code = Isikukood.new(ident)
    errors.add(:ident, 'bad format') unless code.valid?
  end

  def juridical?
    ident_type == IDENT_TYPE_ICO
  end

  def citizen?
    ident_type != IDENT_TYPE_ICO
  end

  def cr_id
    created_by ? created_by.username : nil
  end

  def up_id
    updated_by ? updated_by.username : nil
  end

  def auth_info_matches(pw)
    auth_info == pw
  end

  # generate random id for contact
  def generate_code
    self.code = SecureRandom.hex(4)
  end

  # Find a way to use self.domains with contact
  def domains_owned
    Domain.where(owner_contact_id: id)
  end

  def relations_with_domain?
    return true if domain_contacts.present? || domains_owned.present?
    false
  end

  # should use only in transaction
  def destroy_and_clean
    if relations_with_domain?
      errors.add(:domains, :exist)
      return false
    end
    destroy
  end

  def epp_code_map # rubocop:disable Metrics/MethodLength
    {
      '2302' => [ # Object exists
        [:code, :epp_id_taken]
      ],
      '2305' => [ # Association exists
        [:domains, :exist]
      ],
      '2005' => [ # Value syntax error
        [:phone, :invalid],
        [:email, :invalid]
      ]
    }
  end

  def to_s
    name
  end

  class << self
    # non-EPP

    # EPP
    def extract_attributes(ph, type = :create)
      ph[:postalInfo] = ph[:postalInfo].first if ph[:postalInfo].is_a?(Array)
      contact_hash = {
        phone: ph[:voice],
        ident: ph[:ident],
        email: ph[:email],
        name: ph[:postalInfo].try(:[], :name),
        org_name: ph[:postalInfo].try(:[], :org)
      }
      contact_hash[:auth_info] = ph[:authInfo][:pw] if type == :create
      contact_hash.delete_if { |_k, v| v.nil? }
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

    def search_by_query(query)
      res = search(code_cont: query).result
      res.reduce([]) { |o, v| o << { id: v[:id], display_key: "#{v.name} (#{v.code})" } }
    end
  end

  private
end
