class Registrar < ActiveRecord::Base
  belongs_to :country
  has_many :domains
  has_many :ns_sets
  has_many :epp_users
end
