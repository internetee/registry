class WhiteIp < ApplicationRecord
  include Versions
  include WhiteIp::WhiteIpConcern

  belongs_to :registrar

  attr_accessor :address

  validate :validate_address_format
  validates :ipv4, uniqueness: { scope: :registrar_id }, if: :ipv4?
  validates :ipv6, uniqueness: { scope: :registrar_id }, if: :ipv6?
  validate :validate_only_one_ip
  validate :valid_ipv4?
  validate :valid_ipv6?
  validate :validate_max_ip_count
  before_save :normalize_blank_values

  def normalize_blank_values
    %i[ipv4 ipv6].each { |c| self[c].present? || self[c] = nil }
  end

  def validate_address_format
    return if address.blank?

    ip_address = IPAddr.new(address)
    ip_version = determine_ip_version(ip_address)

    assign_ip_attributes(ip_version)
  rescue IPAddr::InvalidAddressError
    errors.add(:base, :address_invalid)
  end

  def validate_only_one_ip
    if ipv4.present? && ipv6.present?
      errors.add(:base, :ip_must_be_one)
    elsif ipv4.blank? && ipv6.blank?
      errors.add(:base, :ipv4_or_ipv6_must_be_present)
    end
  end

  def validate_max_ip_count
    return if errors.any?

    total_exist = calculate_total_network_addresses(registrar.white_ips)
    total_current = calculate_total_network_addresses([self])
    total = total_exist + total_current
    limit = Setting.ip_whitelist_max_count
    return unless total >= limit

    errors.add(:base, :ip_limit_exceeded, total: total, limit: limit)
  end

  def valid_ipv4?
    return if ipv4.blank?

    IPAddr.new(ipv4, Socket::AF_INET)
  rescue StandardError => _e
    errors.add(:ipv4, :invalid)
  end

  def valid_ipv6?
    return if ipv6.blank?

    IPAddr.new(ipv6, Socket::AF_INET6)
  rescue StandardError => _e
    errors.add(:ipv6, :invalid)
  end

  API = 'api'.freeze
  REGISTRAR = 'registrar'.freeze
  INTERFACES = [API, REGISTRAR].freeze

  scope :api, -> { where('interfaces @> ?::varchar[]', "{#{API}}") }
  scope :registrar_area, -> { where('interfaces @> ?::varchar[]', "{#{REGISTRAR}}") }

  def interfaces=(interfaces)
    super(interfaces.reject(&:blank?))
  end

  def as_csv_row
    [
      ipv4, ipv6,
      interfaces.join(', ').upcase,
      created_at,
      updated_at
    ]
  end

  private

  def determine_ip_version(ip_address)
    return :ipv4 if ip_address.ipv4?
    return :ipv6 if ip_address.ipv6?

    nil
  end

  def assign_ip_attributes(ip_version)
    case ip_version
    when :ipv4
      self.ipv4 = address
      self.ipv6 = nil
    when :ipv6
      self.ipv6 = address
      self.ipv4 = nil
    else
      errors.add(:base, :address_invalid)
    end
  end

  def count_network_addresses(ip)
    address = IPAddr.new(ip)

    if address.ipv4?
      subnet_mask = address.prefix
      (2**(32 - subnet_mask) - 2).abs
    elsif address.ipv6?
      subnet_mask = address.prefix
      (2**(128 - subnet_mask) - 2).abs
    else
      0
    end
  end

  def calculate_total_network_addresses(ips)
    ips.sum { |ip| count_network_addresses(ip.ipv4.presence || ip.ipv6) }
  end
end
