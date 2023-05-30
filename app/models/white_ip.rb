class WhiteIp < ApplicationRecord
  include Versions
  belongs_to :registrar

  validate :valid_ipv4?
  validate :valid_ipv6?
  validate :validate_ipv4_and_ipv6
  validate :validate_only_one_ip
  before_save :normalize_blank_values

  def normalize_blank_values
    %i[ipv4 ipv6].each { |c| self[c].present? || self[c] = nil }
  end

  def validate_ipv4_and_ipv6
    return if ipv4.present? || ipv6.present?

    errors.add(:base, I18n.t(:ipv4_or_ipv6_must_be_present))
  end

  def validate_only_one_ip
    return unless ipv4.present? && ipv6.present?

    errors.add(:base, I18n.t(:ip_must_be_one))
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

  class << self
    # rubocop:disable Style/CaseEquality
    # rubocop:disable Metrics/AbcSize
    def include_ip?(ip)
      return false if ip.blank?

      where(id: ids_including(ip)).any?
    end

    def ids_including(ip)
      ipv4 = ipv6 = []
      ipv4 = select { |white_ip| check_ip4(white_ip.ipv4) === check_ip4(ip) } if check_ip4(ip).present?
      ipv6 = select { |white_ip| check_ip6(white_ip.ipv6) === check_ip6(ip) } if check_ip6(ip).present?
      (ipv4 + ipv6).pluck(:id).flatten.uniq
    end
    # rubocop:enable Style/CaseEquality
    # rubocop:enable Metrics/AbcSize

    def check_ip4(ip)
      IPAddr.new(ip, Socket::AF_INET)
    rescue StandardError => _e
      nil
    end

    def check_ip6(ip)
      IPAddr.new(ip, Socket::AF_INET6)
    rescue StandardError => _e
      nil
    end

    def csv_header
      %w[IPv4 IPv6 Interfaces Created Updated]
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end
  end

  def as_csv_row
    [
      ipv4,
      ipv6,
      interfaces.join(', ').upcase,
      created_at,
      updated_at,
    ]
  end
end
