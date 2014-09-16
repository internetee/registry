class DomainContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :domain

  TECH = 'tech'
  ADMIN = 'admin'
  TYPES = [TECH, ADMIN]

  scope :admin, -> { where(contact_type: ADMIN) }
  scope :tech, -> { where(contact_type: TECH) }
end
