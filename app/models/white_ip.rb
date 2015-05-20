class WhiteIp < ActiveRecord::Base
  include Versions
  belongs_to :registrar

  # rubocop: disable Metrics/LineLength
  validates :ipv4, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_blank: true }
  validates :ipv6, format: { with: /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/, allow_blank: true }
  # rubocop: enable Metrics/LineLength

  validate :validate_ipv4_and_ipv6
  def validate_ipv4_and_ipv6
    return if ipv4.present? || ipv6.present?
    errors.add(:base, I18n.t(:ipv4_or_ipv6_must_be_present))
  end

  EPP = 'epp'
  REPP = 'repp'
  REGISTRAR = 'registrar'
  GLOBAL = 'global'

  INTERFACES = [GLOBAL, EPP, REPP, REGISTRAR]

  scope :epp, -> { where(interface: EPP) }
  scope :repp, -> { where(interface: REPP) }
  scope :registrar, -> { where(interface: REGISTRAR) }
  scope :global, -> { where(interface: GLOBAL) }

  class << self
    def registrar_ip_white?(ip)
      at = WhiteIp.arel_table
      WhiteIp.where(
        at[:interface].eq(REGISTRAR).or(
          at[:interface].eq(GLOBAL)
        ).and(
          at[:ipv4].eq(ip)
        )
      )
    end
  end
end
