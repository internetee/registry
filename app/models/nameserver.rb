class Nameserver < ApplicationRecord
  include Versions # version/nameserver_version.rb
  include EppErrors

  HOSTNAME_REGEXP = /\A(([a-zA-Z0-9]|[a-zA-ZäöüõšžÄÖÜÕŠŽ0-9][a-zA-ZäöüõšžÄÖÜÕŠŽ0-9\-]
    *[a-zA-ZäöüõšžÄÖÜÕŠŽ0-9])\.)
    *([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]
    *[A-Za-z0-9])\z/x

  IPV4_REGEXP = /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}
    ([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/x

  IPV6_REGEXP = /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|
    ([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|
    ([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|
    ([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|
    ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|
    :((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|
    ::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|
    1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|
    1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/x

  belongs_to :domain, required: true

  validates :hostname, presence: true
  validates :hostname, format: { with: HOSTNAME_REGEXP }, allow_blank: true
  validate :validate_ipv4_format
  validate :validate_ipv6_format
  validate :require_ip, if: :glue_record_required?

  before_validation :normalize_attributes
  before_validation :check_puny_symbols
  before_validation :check_label_length

  delegate :name, to: :domain, prefix: true

  self.ignored_columns = %w[legacy_domain_id]

  def epp_code_map
    {
        '2302' => [
            [:hostname, :taken, { value: { obj: 'hostAttr', val: {'hostName': hostname} } }]
        ],
        '2005' => [
            [:hostname, :invalid, { value: { obj: 'hostAttr', val: hostname } }],
            [:hostname, :puny_to_long, { value: { obj: 'hostAttr', val: hostname } }],
            [:ipv4, :invalid, { value: { obj: 'hostAddr', val: ipv4 } }],
            [:ipv6, :invalid, { value: { obj: 'hostAddr', val: ipv6 } }]
        ],
        '2003' => [
            [:ipv4, :blank]
        ]
    }
  end

  def to_s
    hostname
  end

  def hostname=(hostname)
    self[:hostname] = SimpleIDN.to_unicode(hostname)
    self[:hostname_puny] = SimpleIDN.to_ascii(hostname)
  end

  class << self
    def find_by_hash_params params
      params = params.with_indifferent_access
      rel = all
      rel = rel.where(hostname: params[:hostname])
      rel
    end

    def hostnames
      pluck(:hostname)
    end
  end

  private

  def require_ip
    errors.add(:base, :ip_required) if ipv4.blank? && ipv6.blank?
  end

  def glue_record_required?
    return unless hostname? && domain
    DomainName(hostname).domain == domain.name
  end

  def normalize_attributes
    self.hostname = hostname.try(:strip).try(:downcase)
    self.ipv4 = Array(ipv4).reject(&:blank?).map(&:strip)
    self.ipv6 = Array(ipv6).reject(&:blank?).map(&:strip).map(&:upcase)
  end

  def check_label_length
    return unless hostname

    hostname_puny.split('.').each do |label|
      errors.add(:hostname, :puny_to_long) if label.length > 63
    end
  end

  def check_puny_symbols
    regexp = /(\A|\.)..--/
    errors.add(:hostname, :invalid) if hostname.match?(regexp)
  end

  def validate_ipv4_format
    ipv4.to_a.each do |ip|
      errors.add(:ipv4, :invalid) unless ip.match?(IPV4_REGEXP)
    end
  end

  def validate_ipv6_format
    ipv6.to_a.each do |ip|
      errors.add(:ipv6, :invalid) unless ip.match?(IPV6_REGEXP)
    end
  end
end
