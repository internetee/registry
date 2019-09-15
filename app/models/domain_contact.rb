class DomainContact < ApplicationRecord
  # STI: tech_domain_contact
  # STI: admin_domain_contact
  include Versions # version/domain_contact_version.rb
  include EppErrors
  belongs_to :contact
  belongs_to :domain

  attr_accessor :value_typeahead

  def epp_code_map
    {
      '2302' => [
        [:contact_code_cache, :taken, { value: { obj: 'contact', val: contact_code_cache } }]
      ]
    }
  end

  def name
    return 'Tech'  if type == 'TechDomainContact'
    return 'Admin' if type == 'AdminDomainContact'
    ''
  end

  validates :contact, presence: true

  before_save :update_contact_code_cache
  def update_contact_code_cache
    self.contact_code_cache = contact.code
  end

  after_destroy :update_contact
  def update_contact
    Contact.find(contact_id).save
  end

  def value_typeahead
    @value_typeahead || contact.try(:name) || nil
  end
end
