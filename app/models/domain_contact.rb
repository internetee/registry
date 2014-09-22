class DomainContact < ActiveRecord::Base
  include EppErrors
  belongs_to :contact
  belongs_to :domain

  attr_accessor :value_typeahead

  def epp_code_map
    {
      '2302' => [
        [:contact, :taken, { value: { obj: 'contact', val: contact.code } }]
      ]
    }
  end

  TECH = 'tech'
  ADMIN = 'admin'
  TYPES = [TECH, ADMIN]

  validates :contact, presence: true
  validates :contact, uniqueness: { scope: [:domain_id, :contact_type] }

  scope :admin, -> { where(contact_type: ADMIN) }
  scope :tech, -> { where(contact_type: TECH) }

  def admin?
    contact_type == ADMIN
  end

  def tech?
    contact_type == TECH
  end

  def value_typeahead
    @value_typeahead || contact.try(:name) || nil
  end
end
