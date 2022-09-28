class DomainContact < ApplicationRecord
  # STI: tech_domain_contact
  # STI: admin_domain_contact
  include Versions # version/domain_contact_version.rb
  include EppErrors
  belongs_to :contact
  belongs_to :domain

  validates :contact, presence: true

  after_destroy :update_contact
  attr_accessor :value_typeahead
  attr_writer :contact_codes

  self.ignored_columns = %w[legacy_domain_id legacy_contact_id]

  def name
    return 'Tech'  if type == 'TechDomainContact'
    return 'Admin' if type == 'AdminDomainContact'

    ''
  end

  def update_contact
    Contact.find(contact_id).save
  end

  def value_typeahead
    @value_typeahead || contact.try(:name) || nil
  end
end
