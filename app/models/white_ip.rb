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
      Rails.logger.info "Checking if whitelist includes ip:#{ip}"
      return false if ip.blank?

      where(id: ids_including(ip)).any?
    end

    def ids_including(ip)
      ipv4 = ipv6 = []
      if check_ip4(ip).present?
        ipv4 = select { |white_ip| IPAddr.new(white_ip.ipv4, Socket::AF_INET) === check_ip4(ip) }
      end
      if check_ip6(ip).present?
        ipv6 = select { |white_ip| IPAddr.new(white_ip.ipv6, Socket::AF_INET6) === check_ip6 }
      end
      (ipv4 + ipv6).pluck(:id).flatten.uniq
    end
    # rubocop:enable Style/CaseEquality

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

  end
end
