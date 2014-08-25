class Contact < ActiveRecord::Base
  # TODO Foreign contact will get email with activation link/username/temp password
  # TODO Phone number validation, in first phase very minimam in order to support current registries

  include EppErrors

  EPP_ATTR_MAP = {}

  has_one :address
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts

  belongs_to :created_by, class_name: 'EppUser', foreign_key: :created_by_id
  belongs_to :updated_by, class_name: 'EppUser', foreign_key: :updated_by_id

  accepts_nested_attributes_for :address

  validates_presence_of :code, :name, :phone, :email, :ident

  validate :ident_must_be_valid

  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/ # /\+\d{3}\.\d+/
  validates :email, format: /@/

  validates_uniqueness_of :code, message: :epp_id_taken

  IDENT_TYPE_ICO = 'ico'
  IDENT_TYPES = [
    IDENT_TYPE_ICO, # Company registry code (or similar)
    'op',           # Estonian ID
    'passport',     # Passport number
    'birthday'      # Birthday date
  ]

  def ident_must_be_valid
    # TODO Ident can also be passport number or company registry code.
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

  def crID
    created_by ? created_by.username : nil
  end

  def upID
    updated_by ? updated_by.username : nil
  end

  def auth_info_matches(pw)
    return true if auth_info == pw
    false
  end

  # Find a way to use self.domains with contact
  def domains_owned
    Domain.find_by(owner_contact_id: id)
  end

  def relations_with_domain?
    return true if domain_contacts.present? || domains_owned.present?
    false
  end

  # should use only in transaction
  def destroy_and_clean
    clean_up_address

    if relations_with_domain?
      errors.add(:domains, :exist)
      return false
    end
    destroy
  end

  def epp_code_map
    {
      '2302' => [ # Object exists
        [:code, :epp_id_taken]
      ],
      '2303' => # Object does not exist
        [:not_found, :epp_obj_does_not_exist],
      '2305' => [ # Association exists
        [:domains, :exist]
      ],
      '2005' => [ # Value syntax error
        [:phone, :invalid],
        [:email, :invalid]
      ]
    }
  end

  class << self
    def extract_attributes(ph, type = :create)
      contact_hash = {
        phone: ph[:voice],
        ident: ph[:ident],
        email: ph[:email]
      }

      contact_hash = contact_hash.merge({
        name: ph[:postalInfo][:name],
        org_name: ph[:postalInfo][:org]
      }) if ph[:postalInfo].is_a? Hash

      contact_hash[:code] = ph[:id] if type == :create

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
  end

  private

  def clean_up_address
    address.destroy if address
  end
end
