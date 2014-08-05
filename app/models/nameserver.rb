class Nameserver < ActiveRecord::Base
  belongs_to :registrar
  has_and_belongs_to_many :domains

  validates :hostname, hostname: true
  validates :ip, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_nil: true}
end
