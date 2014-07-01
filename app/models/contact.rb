class Contact < ActiveRecord::Base
  #TODO Estonian id validation
  #TODO Foreign contact will get email with activation link/username/temp password
  #TODO Phone number validation, in first phase very minimam in order to support current registries
  has_many :addresses
end
