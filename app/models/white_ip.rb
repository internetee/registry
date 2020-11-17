class WhiteIp < ApplicationRecord
  include Versions
  belongs_to :registrar

  validate :valid_ipv4?
  validate :valid_ipv6?

  validate :validate_ipv4_and_ipv6
  def validate_ipv4_and_ipv6
    return if ipv4.present? || ipv6.present?
    errors.add(:base, I18n.t(:ipv4_or_ipv6_must_be_present))
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

  API = 'api'
  REGISTRAR = 'registrar'
  INTERFACES = [API, REGISTRAR]

  scope :api, -> { where("interfaces @> ?::varchar[]", "{#{API}}") }
  scope :registrar_area, -> { where("interfaces @> ?::varchar[]", "{#{REGISTRAR}}") }

  def interfaces=(interfaces)
    super(interfaces.reject(&:blank?))
  end

  class << self
    # rubocop:disable Style/CaseEquality
    def include_ip?(ip)
      ipv4 = select { |white_ip| IPAddr.new(white_ip.ipv4, Socket::AF_INET) === IPAddr.new(ip) }
      ipv6 = select { |white_ip| IPAddr.new(white_ip.ipv6, Socket::AF_INET6) === IPAddr.new(ip) }
      ids = (ipv4 + ipv6).pluck(:id).flatten.uniq
      where(id: ids).any?
    end
    # rubocop:enable Style/CaseEquality
  end
end
