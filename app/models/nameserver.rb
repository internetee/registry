class Nameserver < ActiveRecord::Base
  belongs_to :registrar
  has_and_belongs_to_many :domains

  validates :hostname, hostname: true
end
