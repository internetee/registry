class Nameserver < ActiveRecord::Base
  include EppErrors

  belongs_to :registrar
  belongs_to :domain

  # rubocop: disable Metrics/LineLength
  validates :hostname, format: { with: /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/ }
  validates :ipv4, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_blank: true }
  validates :ipv6, format: { with: /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/, allow_blank: true }
  # rubocop: enable Metrics/LineLength

  # archiving
  has_paper_trail class_name: 'NameserverVersion'
  after_destroy :domain_version

  before_validation :normalize_attributes

  def epp_code_map
    {
      '2302' => [
        [:hostname, :taken, { value: { obj: 'hostObj', val: hostname } }]
      ],
      '2005' => [
        [:hostname, :invalid, { value: { obj: 'hostObj', val: hostname } }],
        [:ipv4, :invalid, { value: { obj: 'hostAddr', val: ipv4 } }],
        [:ipv6, :invalid, { value: { obj: 'hostAddr', val: ipv6 } }]
      ],
      '2306' => [
        [:ipv4, :blank]
      ]
    }
  end

  def snapshot
    {
      hostname: hostname,
      ipv4: ipv4,
      ipv6: ipv6
    }
  end

  def normalize_attributes
    self.hostname = hostname.try(:strip).try(:downcase)
    self.ipv4 = ipv4.try(:strip)
    self.ipv6 = ipv6.try(:strip).try(:upcase)
  end

  def domain_version
    domain.touch_with_version if domain.valid?
  end

  def to_s
    hostname
  end
end
