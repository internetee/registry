class NsSet < ActiveRecord::Base
  belongs_to :registrar
  has_many :domains
  has_and_belongs_to_many :nameservers
end
