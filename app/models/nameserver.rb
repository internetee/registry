class Nameserver < ActiveRecord::Base
  has_and_belongs_to_many :ns_sets
end
