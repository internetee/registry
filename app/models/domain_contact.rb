class DomainContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :domain

  TECH = 'tech'
  ADMIN = 'admin'
  TYPES = [TECH, ADMIN]
end
