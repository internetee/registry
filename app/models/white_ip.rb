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

    errors.add(:ipv4, :invalid) unless valid_ip_addr?(ipv4)
  end

  def valid_ipv6?
    return if ipv6.blank?

    errors.add(:ipv6, :invalid) unless valid_ip_addr?(ipv6)
  end

  def valid_ip_addr?(ip)
    IPAddr.new(ip)
    true
  rescue IPAddr::InvalidAddressError => _e
    false
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
      logger.info "Checking whitelisting of ip #{ip}"
      scoped = scope == :api ? api_scope(registrar) : registrar_area_scope(registrar)
      whitelist = scoped.pluck(:ipv4, :ipv6).flatten.reject(&:blank?)
                        .uniq.map { |white_ip| IPAddr.new(white_ip) }
      check = whitelist.any? { |white_ip| white_ip === IPAddr.new(ip.to_s) }
      logger.info "Check result is #{check}"
      check
    end
    # rubocop:enable Style/CaseEquality
  end
end
