class DomainContact < ActiveRecord::Base
  include EppErrors
  belongs_to :contact
  belongs_to :domain

  after_create :domain_snapshot
  after_destroy :domain_snapshot
  #  after_save :domain_snapshot

  attr_accessor :value_typeahead

  def epp_code_map
    {
      '2302' => [
        [:contact_code_cache, :taken, { value: { obj: 'contact', val: contact_code_cache } }]
      ]
    }
  end

  TECH = 'tech'
  ADMIN = 'admin'
  TYPES = [TECH, ADMIN]

  validates :contact, presence: true

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

  def domain_snapshot
    return true if domain.nil?
    return true if domain.versions.count == 0 # avoid snapshot on creation
    domain.create_version
    true
  end
end
