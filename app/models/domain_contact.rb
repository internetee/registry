class DomainContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :domain

  scope :tech, -> {where(contact_type: :tech)}
end
