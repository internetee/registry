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

    errors.add(:ipv4, :invalid) unless self.class.ip_to_check(ipv4).is_a? IPAddr
  end

  def valid_ipv6?
    return if ipv6.blank?

    errors.add(:ipv6, :invalid) unless self.class.ip_to_check(ipv6).is_a? IPAddr
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
    def registrar_area_scope(registrar)
      registrar.present? ? registrar.white_ips.registrar_area : registrar_area
    end

    def api_scope(registrar)
      registrar.present? ? registrar.white_ips.api : api
    end

    # rubocop:disable Style/CaseEquality
    def include_ip?(ip:, scope: :api, registrar:)
      scoped = scope == :api ? api_scope(registrar) : registrar_area_scope(registrar)
      whitelist = scoped.pluck(:ipv4, :ipv6).flatten.reject(&:blank?)
                        .uniq.map { |white_ip| ip_to_check(white_ip) }
      check = whitelist.any? { |white_ip| white_ip === ip_to_check(ip) }
      check
    end
    # rubocop:enable Style/CaseEquality

    def ip_to_check(ip)
      result = if ip.is_a? IPAddr
                 ip
               elsif ip.is_a? String
                 IPAddr.new(ip)
               end
      result
    rescue StandardError => _e
      ip
    end
  end
end
