class WhiteIp < ApplicationRecord
  include Versions
  include Audit
  belongs_to :registrar

  validates :ipv4, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_blank: true }
  validates :ipv6, format: { with: /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/, allow_blank: true }

  validate :validate_ipv4_and_ipv6
  def validate_ipv4_and_ipv6
    return if ipv4.present? || ipv6.present?
    errors.add(:base, I18n.t(:ipv4_or_ipv6_must_be_present))
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
    def include_ip?(ip)
      where('ipv4 = :ip OR ipv6 = :ip', ip: ip).any?
    end
  end
end
