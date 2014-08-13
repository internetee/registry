class Nameserver < ActiveRecord::Base
  include EppErrors

  EPP_CODE_MAP = {
    '2005' => ['Hostname is invalid', 'IPv4 is invalid']
  }

  EPP_ATTR_MAP = {
    hostname: 'hostName'
  }

  belongs_to :registrar
  has_and_belongs_to_many :domains

  validates :hostname, format: { with: /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/ }
  validates :ipv4, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_nil: true }
end
