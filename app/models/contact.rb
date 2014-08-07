class Contact < ActiveRecord::Base
  #TODO Foreign contact will get email with activation link/username/temp password
  #TODO Phone number validation, in first phase very minimam in order to support current registries

  include EppErrors

  EPP_CODE_MAP = {
    '2302' => ['Contact id already exists'],
    '2303' => [:not_found, :epp_obj_does_not_exist],
    '2005' => ['Phone nr is invalid', 'Email is invalid']
  }

  EPP_OBJ = 'contact'

  has_one :address
  has_many :domain_contacts
  has_many :domains, through: :domain_contacts

  belongs_to :created_by, class_name: 'EppUser', foreign_key: :created_by_id
  belongs_to :updated_by, class_name: 'EppUser', foreign_key: :updated_by_id

  accepts_nested_attributes_for :address

  validates_presence_of :code, :name, :phone, :email, :ident

  validate :ident_must_be_valid

  validates :phone, format: /\+[0-9]{1,3}\.[0-9]{1,14}?/ #/\+\d{3}\.\d+/
  validates :email, format: /@/

  validates_uniqueness_of :code, message: :epp_id_taken

  IDENT_TYPE_ICO = 'ico'
  IDENT_TYPES = [
    IDENT_TYPE_ICO, #Company registry code (or similar)
    "op",           #Estonian ID
    "passport",     #Passport number
    "birthday"      #Birthday date
  ]

  CONTACT_TYPE_TECH = 'tech'
  CONTACT_TYPE_ADMIN = 'admin'
  CONTACT_TYPES = [CONTACT_TYPE_TECH, CONTACT_TYPE_ADMIN]

  def ident_must_be_valid
    #TODO Ident can also be passport number or company registry code.
    #so have to make changes to validations (and doc/schema) accordingly
    return true unless ident.present? && ident_type.present? && ident_type == "op"
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

  class << self
    def check_availability(codes)
      codes = [codes] if codes.is_a?(String)

      res = []
      codes.each do |x|
        if Contact.find_by(code: x)
          res << {code: x, avail: 0, reason: 'in use'}
        else
          res << {code: x, avail: 1}
        end
      end

      res
    end
  end

end
